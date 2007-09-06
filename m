From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH] 1/2 SELinux: Add get, set,
	and cloning of superblock	security information
Date: Thu, 06 Sep 2007 12:15:12 -0400
Message-ID: <1189095312.3418.9.camel@localhost.localdomain>
References: <636439.78887.qm@web36607.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: steved@redhat.com, trond.myklebust@fys.uio.no,
	nfs@lists.sourceforge.net, selinux@tycho.nsa.gov, sds@tycho.nsa.gov
To: casey@schaufler-ca.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ITK0v-0005JZ-5u
	for nfs@lists.sourceforge.net; Thu, 06 Sep 2007 09:15:29 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ITK0z-0007Ln-HS
	for nfs@lists.sourceforge.net; Thu, 06 Sep 2007 09:15:33 -0700
In-Reply-To: <636439.78887.qm@web36607.mail.mud.yahoo.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-09-06 at 08:59 -0700, Casey Schaufler wrote:
> --- Eric Paris <eparis@redhat.com> wrote:
> 
> > Adds security_get_sb_mnt_opts, security_set_sb_mnt_opts, and
> > security_clont_sb_mnt_opts to the LSM and to SELinux.  This is in
> > preparation for NFS to be able to own its own mount options and remove
> > the NFS specific code from SELinux.
> 
> What is the purpose of security_clone_sb_mnt_opts? I see where it is
> being used, but it's not clear to me why it is necessary. The old SELinux
> code doesn't clone the options, it filters out the ones it cares about.
> If that is the behavior you'd expect of this hook, I suggest the name
> reflect that, perhaps security_filter_sb_mnt_opts.

I'm not sure what you mean by filter and I don't know which code you are
referring to.

At the moment the only user of clone is nfs nohide mounts.  Given an
exports list like

/export *()
/export/nohide *(nohide)

where /export/nohide actually crosses a filesystem boundry the nfs
client will quietly mount the new export on your machine as soon as you
enter that directory.  Assuming the user originally mounted /export with
some security options when nfs mounts this new export there needs to be
some way to propogate those security options forward to this new mount.
So the one usage of clone simply takes the security options from the
superblock related to /export and applies those to the new security
block related to /export/nohide

-Eric


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
