Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40638 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752412AbdK0Nvi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 27 Nov 2017 08:51:38 -0500
Date: Mon, 27 Nov 2017 08:51:37 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Alexander Hermes <Alexander.Hermes@metaswitch.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [Req for Help] Issues with SELinux (labelled) NFS after
 upgrading kernel 3.10.0-327 =>3.10.0-693
Message-ID: <20171127135137.jbbfggdi7jbncve3@tonberry.usersys.redhat.com>
References: <BN1PR0201MB067346CD800DDFDFF31CD2FFFC230@BN1PR0201MB0673.namprd02.prod.outlook.com>
 <20171121161725.ltsh6jk6dtetl7ui@tonberry.usersys.redhat.com>
 <BN1PR0201MB0673393B908EB62C6691CEE4FC230@BN1PR0201MB0673.namprd02.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BN1PR0201MB0673393B908EB62C6691CEE4FC230@BN1PR0201MB0673.namprd02.prod.outlook.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 21 Nov 2017, Alexander Hermes wrote:

> > Folks,
> > 
> > I'm looking for some guidance on how to troubleshoot/debug an issue with (SELinux) labels over NFS that we've been having as a result of a kernel upgrade - description below.
> > I looked around on http://linux-nfs.org but was not able to find how to debug this kind of issue with labels - everything I found relates to more fundamental issues like mounts plain not working. 
> > 
> > With apologies for sending this to the devel mailing list, could you please help me get to the bottom of this? Or redirect me to somewhere / someone that can?
> > 
> > Thank you very much,
> > 
> > Alexander Hermes
> > 
> > ----
> > 
> > ## Summary
> > 
> > In upgrading our servers from CentOS 7.3 to 7.4 we upgraded the kernel from 3.10.0-327.36.2.el7.x86_64 to 3.10.0-693.2.2.el7.x86_64. As a result, NFS v4.2 mounts mounted via /etc/fstab at boot do not have proper SElinux label support - attempting to change labels on a mounted file leads to "Operation Not Supported". `ls -lZ` shows the incorrect labels. Upon rebooting to the earlier kernel version the issue goes away.
> > 
> > ## Background
> > 
> > As part of our gitlab HA deployment we use NFS to host data on a back end server that is then mounted by application servers (cf. https://docs.gitlab.com/ce/administration/high_availability/nfs.html). To do this we have a fairly typical setup where the server (in this example "enfigitback2-devel") exports a bunch of mounts via /etc/exports which are then mounted on a couple of application servers ("enfigitfront1-devel" / "enfigitfront2-devel").
> > 
> > ## The issue
> > 
> > On the new kernel I am not able to change or view the SELinux labels of files / directories mounted on the client:
> > 
> > ```
> > [root@enfigitfront2-devel ~]# chcon --recursive --type ssh_home_t 
> > /var/opt/gitlab/.ssh/authorized_keys
> > chcon: failed to change context of 
> > '/var/opt/gitlab/.ssh/authorized_keys' to 
> > 'system_u:object_r:ssh_home_t:s0': Operation not supported 
> > [root@enfigitfront2-devel ~]# uname -r
> > 3.10.0-693.2.2.el7.x86_64
> > ```
> > On the old kernel I am:
> > 
> > ```
> > [root@enfigitfront1-devel ~]# chcon --recursive --type ssh_home_t 
> > /var/opt/gitlab/.ssh/authorized_keys
> > [root@enfigitfront1-devel ~]# uname -r
> > 3.10.0-327.36.2.el7.x86_64
> > ```
> > 
> > We can't keep using the old kernel forever so I'd like to get to the bottom of this - what could this be due to? How can I debug this further to understand where the "Operation not supported" is coming from?
> > 
> > ## Server details
> > Distro: CentOS 7.3 / 7.4
> > Kernel (`uname -r`): 
> >  * 3.10.0-514.10.2.el7.x86_64 (server)
> > * 3.10.0-693.2.2.el7.x86_64 (client - new)
> > * 3.10.0-327.36.2.el7.x86_64 (client - old)
> > nfs-utils: RPM package version 1.3.0
> > 
> >  
> > Server mount option example:
> > /export/.ssh 172.18.10.148(rw,sync,no_root_squash) 
> > 172.18.10.151(rw,sync,no_root_squash)
> 
> Add "security_label" to the export options above.  If you don't see "security_label" listed in the exports(5) man page then you need to upgrade your nfs-utils package.
> 
> -Scott
> 
> > 
> > Client mount options (/etc/fstab):
> > enfigitback2-devel.datcon.co.uk:/export/.ssh    /var/opt/gitlab/.ssh    nfs     defaults,soft,v4.2,rsize=1048576,wsize=1048576,noatime,_netdev,lookupcache=none 0       0
> > 
> > ## Debugging I've done
> > 
> > ### Mounting by hand
> > I tried to mount one of the exported mounts "by hand" using `mount` and found the following:
> > * mounting the same export on a different mount point using the same 
> > options as in /etc/fstab yields a mount that has the same issue
> > * mounting with `nosharecache` results in a mount that *does not* have the issue.
> > 
> > 
> 
> 
> Hi Scott,
> 
> Thank you for pointing out "security_label". I have applied the option...
> 
> 	/export/.ssh 172.18.10.148(rw,sync,no_root_squash,security_label) 172.18.10.151(rw,sync,no_root_squash,security_label)
> 
> and rebooted both server and client (in that order), but I still see the same behaviour as before on the server with the uplevel kernel:
> 
> 	[root@enfigitfront2-devel ~]# chcon --recursive --type ssh_home_t /var/opt/gitlab/.ssh/authorized_keys
> 	chcon: failed to change context of '/var/opt/gitlab/.ssh/authorized_keys' to 'system_u:object_r:ssh_home_t:s0': Operation not supported
> 
> I notice that the exports(5) man page mentions " This will only work if all clients use a consistent security policy." under security_label. I'm not sure what a "consistent security policy" means - what does this mean in terms of options/configuration? 

I'm assuming  that means you don't want some clients using full labeled
NFS, others mounting with the context= mount option, and others with
SELinux completely disabled.  With labeled NFS, the creation and
enforcement of labels happens on the client side and the server just
stores the labels.

Anyways, I missed the fact that your clients are using an earlier
kernel.  In order to get the desired behavior when mounting an NFS
server that is using the "security_label" export option, you're pretty
much going to need to run an updated kernel on the clients too...
specifically one with commit 0b4d3452b "security/selinux: allow
security_sb_clone_mnt_opts to enable/disable native labeling behavior".
AFAIK CentOS 7.4 should have it (because RHEL 7.4 has it).

-Scott


> 
> Thanks for the help,
> Alex
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
