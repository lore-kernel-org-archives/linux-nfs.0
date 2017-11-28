Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43842 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752177AbdK1RXT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 28 Nov 2017 12:23:19 -0500
Date: Tue, 28 Nov 2017 12:23:18 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Alexander Hermes <Alexander.Hermes@metaswitch.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [Req for Help] Issues with SELinux (labelled) NFS after
 upgrading kernel 3.10.0-327 =>3.10.0-693
Message-ID: <20171128172318.cqv3pv4kzkxkckds@tonberry.usersys.redhat.com>
References: <BN1PR0201MB067346CD800DDFDFF31CD2FFFC230@BN1PR0201MB0673.namprd02.prod.outlook.com>
 <20171121161725.ltsh6jk6dtetl7ui@tonberry.usersys.redhat.com>
 <BN1PR0201MB0673393B908EB62C6691CEE4FC230@BN1PR0201MB0673.namprd02.prod.outlook.com>
 <20171127135137.jbbfggdi7jbncve3@tonberry.usersys.redhat.com>
 <20171127155727.GA25581@fieldses.org>
 <BN1PR0201MB067317A6EDC7232B2A16BC00FC3A0@BN1PR0201MB0673.namprd02.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <BN1PR0201MB067317A6EDC7232B2A16BC00FC3A0@BN1PR0201MB0673.namprd02.prod.outlook.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 28 Nov 2017, Alexander Hermes wrote:

> > On Tue, 21 Nov 2017, Alexander Hermes wrote:
> > 
> > > > Folks,
> > > > 
> > > > I'm looking for some guidance on how to troubleshoot/debug an issue with (SELinux) labels over NFS that we've been having as a result of a kernel upgrade - description below.
> > > > I looked around on http://linux-nfs.org but was not able to find how to debug this kind of issue with labels - everything I found relates to more fundamental issues like mounts plain not working. 
> > > > 
> > > > With apologies for sending this to the devel mailing list, could you please help me get to the bottom of this? Or redirect me to somewhere / someone that can?
> > > > 
> > > > Thank you very much,
> > > > 
> > > > Alexander Hermes
> > > > 
> > > > ----
> > > > 
> > > > ## Summary
> > > > 
> > > > In upgrading our servers from CentOS 7.3 to 7.4 we upgraded the kernel from 3.10.0-327.36.2.el7.x86_64 to 3.10.0-693.2.2.el7.x86_64. As a result, NFS v4.2 mounts mounted via /etc/fstab at boot do not have proper SElinux label support - attempting to change labels on a mounted file leads to "Operation Not Supported". `ls -lZ` shows the incorrect labels. Upon rebooting to the earlier kernel version the issue goes away.
> > > > 
> > > > ## Background
> > > > 
> > > > As part of our gitlab HA deployment we use NFS to host data on a back end server that is then mounted by application servers (cf. https://docs.gitlab.com/ce/administration/high_availability/nfs.html). To do this we have a fairly typical setup where the server (in this example "enfigitback2-devel") exports a bunch of mounts via /etc/exports which are then mounted on a couple of application servers ("enfigitfront1-devel" / "enfigitfront2-devel").
> > > > 
> > > > ## The issue
> > > > 
> > > > On the new kernel I am not able to change or view the SELinux labels of files / directories mounted on the client:
> > > > 
> > > > ```
> > > > [root@enfigitfront2-devel ~]# chcon --recursive --type ssh_home_t 
> > > > /var/opt/gitlab/.ssh/authorized_keys
> > > > chcon: failed to change context of 
> > > > '/var/opt/gitlab/.ssh/authorized_keys' to
> > > > 'system_u:object_r:ssh_home_t:s0': Operation not supported 
> > > > [root@enfigitfront2-devel ~]# uname -r
> > > > 3.10.0-693.2.2.el7.x86_64
> > > > ```
> > > > On the old kernel I am:
> > > > 
> > > > ```
> > > > [root@enfigitfront1-devel ~]# chcon --recursive --type ssh_home_t 
> > > > /var/opt/gitlab/.ssh/authorized_keys
> > > > [root@enfigitfront1-devel ~]# uname -r
> > > > 3.10.0-327.36.2.el7.x86_64
> > > > ```
> > > > 
> > > > We can't keep using the old kernel forever so I'd like to get to the bottom of this - what could this be due to? How can I debug this further to understand where the "Operation not supported" is coming from?
> > > > 
> > > > ## Server details
> > > > Distro: CentOS 7.3 / 7.4
> > > > Kernel (`uname -r`): 
> > > >  * 3.10.0-514.10.2.el7.x86_64 (server)
> > > > * 3.10.0-693.2.2.el7.x86_64 (client - new)
> > > > * 3.10.0-327.36.2.el7.x86_64 (client - old)
> > > > nfs-utils: RPM package version 1.3.0
> > > > 
> > > >  
> > > > Server mount option example:
> > > > /export/.ssh 172.18.10.148(rw,sync,no_root_squash)
> > > > 172.18.10.151(rw,sync,no_root_squash)
> > > 
> > > Add "security_label" to the export options above.  If you don't see "security_label" listed in the exports(5) man page then you need to upgrade your nfs-utils package.
> > > 
> > > -Scott
> > > 
> > > > 
> > > > Client mount options (/etc/fstab):
> > > > enfigitback2-devel.datcon.co.uk:/export/.ssh    /var/opt/gitlab/.ssh    nfs     defaults,soft,v4.2,rsize=1048576,wsize=1048576,noatime,_netdev,lookupcache=none 0       0
> > > > 
> > > > ## Debugging I've done
> > > > 
> > > > ### Mounting by hand
> > > > I tried to mount one of the exported mounts "by hand" using `mount` and found the following:
> > > > * mounting the same export on a different mount point using the 
> > > > same options as in /etc/fstab yields a mount that has the same 
> > > > issue
> > > > * mounting with `nosharecache` results in a mount that *does not* have the issue.
> > > > 
> > > > 
> > > 
> > > 
> > > Hi Scott,
> > > 
> > > Thank you for pointing out "security_label". I have applied the option...
> > > 
> > > 	/export/.ssh 172.18.10.148(rw,sync,no_root_squash,security_label) 
> > > 172.18.10.151(rw,sync,no_root_squash,security_label)
> > > 
> > > and rebooted both server and client (in that order), but I still see the same behaviour as before on the server with the uplevel kernel:
> > > 
> > > 	[root@enfigitfront2-devel ~]# chcon --recursive --type ssh_home_t /var/opt/gitlab/.ssh/authorized_keys
> > > 	chcon: failed to change context of 
> > > '/var/opt/gitlab/.ssh/authorized_keys' to 
> > > 'system_u:object_r:ssh_home_t:s0': Operation not supported
> > > 
> > > I notice that the exports(5) man page mentions " This will only work if all clients use a consistent security policy." under security_label. I'm not sure what a "consistent security policy" means - what does this mean in terms of options/configuration? 
> > 
> > I'm assuming  that means you don't want some clients using full 
> > labeled NFS, others mounting with the context= mount option, and 
> > others with SELinux completely disabled.  With labeled NFS, the 
> > creation and enforcement of labels happens on the client side and the 
> > server just stores the labels.
> 
> So also for example if the clients disagree about how to label files in your home directory, or something, then things will likely break.  I don't know how big a problem that is in practice.
> 
> --b.
> 
> > 
> > Anyways, I missed the fact that your clients are using an earlier 
> > kernel.  In order to get the desired behavior when mounting an NFS 
> > server that is using the "security_label" export option, you're pretty 
> > much going to need to run an updated kernel on the clients too...
> > specifically one with commit 0b4d3452b "security/selinux: allow 
> > security_sb_clone_mnt_opts to enable/disable native labeling behavior".
> > AFAIK CentOS 7.4 should have it (because RHEL 7.4 has it).
> > 
> > -Scott
> > 
> > 
> > > 
> > > Thanks for the help,
> > > Alex
> > > --
> 
> Hi,
> 
> Thanks for the reply. Yes, I imagine there'd be problems if clients are confused about what labels are applied, but I just wanted to check if anyone knew of that actually preventing other clients from reading or setting labels at all (throwing "Operation not supported" errors). It sounds from what you are saying like that is _not_ the case.

That's correct.

> 
> Scott, I just want to clarify your comment about clients using an earlier kernel.  Since my original message we now have the following kernels
> 
> Server: 			3.10.0-693.5.2.el7.x86_64
> Client (working): 	3.10.0-327.36.2.el7.x86_64
> Client (non-working): 	3.10.0-693.2.2.el7.x86_64
> 
> So it's the _working_ client which has the down-level kernel.

That's the opposite from what I'm seeing if I install the RHEL kernels
corresponding to the CentOS versions you have listed.

> Are you saying it needs to be up-level also for this to work? Or do you mean that all of the versions are too old somehow? 
> This was working when all servers were down-level (CentOS 7.3 kernel so 3.10-327) _without_ the "security_label" exports option - did the new kernel tighten the security such that this is now required?

Yes, I was saying that in order to use the "security_label" option, your
NFS server and NFS clients need to be running 7.4 kernels.  But it
sounds like there's something else going on here that I'm not
understanding.  Here's what I see when I install the same kernel
versions that you have.

On my NFS server I have a single export with the "security_label"
option:

[root@nfsserver ~]# uname -r
3.10.0-693.5.2.el7.x86_64
[root@nfsserver ~]# cat /etc/exports
/export *(rw,insecure,no_root_squash,security_label)
[root@nfsserver ~]# exportfs -v
/export         <world>(rw,sync,wdelay,hide,no_subtree_check,security_label,sec=sys,insecure,no_root_squash,no_all_squash)

If I mount using the older kernel, I can see the label but I can't
change it:

[root@rhel72 ~]# uname -r
3.10.0-327.36.2.el7.x86_64
[root@rhel72 ~]# mount -o v4.2 nfsserver:/export /mnt/t
[root@rhel72 ~]# ls -Z /mnt/t/file
-rw-r--r--. root root system_u:object_r:etc_t:s0       /mnt/t/file
[root@rhel72 ~]# chcon -t usr_t /mnt/t/file
chcon: failed to change context of ‘/mnt/t/file’ to ‘system_u:object_r:usr_t:s0’: Operation not supported

If I mount using the newer kernel, I can see and change the label:

[root@rhel74 ~]# uname -r
3.10.0-693.2.2.el7.x86_64
[root@rhel74 ~]# mount -o v4.2 nfsserver:/export /mnt/t
[root@rhel74 ~]# ls -Z /mnt/t
-rw-r--r--. root root system_u:object_r:etc_t:s0       file
[root@rhel74 ~]# chcon -t usr_t /mnt/t/file
[root@rhel74 ~]# ls -Z /mnt/t
-rw-r--r--. root root system_u:object_r:usr_t:s0       file

To answer your question, on the NFS server side the older kernel would
always send the individual security labels and a change was made to
make that behavior be opt-in because it was causing problems for some
users (Bruce can correct me on that if I'm wrong).

On the client side there was a problem with setting the appropriate flag
on the superblock that had to do with the way NFSv4 mounts are done. The
client mounts the NFSv4 root and then does a path walk to the real
export.  When it gets to the real export it clones the superblock from
the NFSv4 root.  The flag was not getting set on the clone.  That's what
the commit that I pointed out earlier was fixing.
> 
> Separately, do either of you know of a sensible way I can debug the root cause for the issue further (to get a more detail why "Operation not supported" is thrown)? I don't know the kernel source at all so just reading the code is not viable for me (without some guidance), but is there some logging or more verbose output I can turn on?

There isn't really any verbose logging that I can think of.  When you
get "Operation not supported" from chcon, it pretty much means that the
mount doesn't have the SBLABEL_MNT flag set (RHEL uses an older flag
SE_SBLABELSUPP but it's really the same thing).  You can see whether the
flag is set by looking for the text "seclabel" in the mount options for
your mount in /proc/mounts.  On the older kernel I see this:

[root@rhel72 ~]# grep nfs4 /proc/mounts
nfsserver:/export /mnt/t nfs4 rw,relatime,vers=4.2,rsize=524288,wsize=524288,...

and on the newer kernel I see this:

[root@rhel74 ~]# grep nfs4 /proc/mounts
nfsserver:/export /mnt/t nfs4 rw,seclabel,relatime,vers=4.2,rsize=524288,wsize=524288,...
                                 ^^^^^^^^

The other thing you can look at is the caps field in
/proc/self/mountstats.  If the server has security labels enabled then
the caps field will have NFS_CAP_SECURITY_LABEL set, which is defined as

#define NFS_CAP_SECURITY_LABEL (1U << 18)

You can take the value from the caps field and plug it into a bash printf

[root@rhel74 ~]# grep caps /proc/self/mountstats
        caps:   caps=0x1ffffdf,wtmult=512,dtsize=32768,bsize=0,namlen=255
[root@rhel74 ~]# printf "%x\n" $(( 0x1ffffdf & (1<<18) ))
40000

If you see 0 instead of 40000 then NFS_CAP_SECURITY_LABEL isn't set.

On the older kernel I still see NFS_CAP_SECURITY_LABEL set:

[root@rhel72 ~]# grep caps /proc/self/mountstats
        caps:   caps=0x3fffff,wtmult=512,dtsize=32768,bsize=0,namlen=255
[root@rhel72 ~]# printf "%x\n" $(( 0x3fffff & (1<<18) ))
40000

So in my case the chcon is failing on the older kernel due to the
absence of the SBLABEL_MNT/SE_SBLABELSUPP flag.

-Scott
> 
> Alex
