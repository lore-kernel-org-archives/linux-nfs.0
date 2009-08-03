From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [Patch 7/8] NFS Mount Configuration File (Vers 2)
Date: Mon, 3 Aug 2009 11:57:24 -0400
Message-ID: <20090803155724.GG28838@fieldses.org>
References: <4A76F8E6.2010607@RedHat.com> <4A76FB3B.1070004@RedHat.com> <20090803153113.GC28838@fieldses.org> <4A7707EA.104@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60880 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755341AbZHCP5X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Aug 2009 11:57:23 -0400
In-Reply-To: <4A7707EA.104-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 03, 2009 at 11:53:14AM -0400, Steve Dickson wrote:
> 
> 
> On 08/03/2009 11:31 AM, J. Bruce Fields wrote:
> >> +.SH MOUNT CONFIGURATION FILE
> >> +All of the mount options described in the previous section can also be configured in
> >> +the 
> >> +.I /etc/nfsmount.conf 
> >> +file. This configuration file is made up of three
> >> +different sections: Global, Server and MountPoint. See 
> >> +.BR nfsmount.conf(5)
> >> +for details.
> >> +.PP
> >> +The mount command parses section in a particular order, and will not use
> >> +options that were set in previous sections.  The order of precedence is as follows:
> >> +
> >> +.B Command line option 
> >> +.RS
> >> +options set on the command line will always be used.
> >> +.RE
> >> +.B Mount Point options
> >> +.RS
> >> +options set in the 
> >> +.B [<Mount_Point>]
> >> +section  will
> >> +be used only if they are not specified on the command line.
> >> +.RE
> >> +.B Server options
> >> +.RS
> >> +options set in the 
> >> +.B [<Server_Name>] 
> >> +section will be used
> >> +if they are not specified on the command  line or  the
> >> +mount point section.
> >> +.RE
> >> +.B Global options 
> >> +.RS
> >> +options set in the 
> >> +.B [NFSMount_Global_Options] 
> >> +will be used if they are not specified on the command line, mount point 
> >> +section, or the server section.
> >> +.RE
> >>  .SH EXAMPLES
> >>  To mount an export using NFS version 2,
> >>  use the
> >> diff --git a/utils/mount/nfsmount.conf.man b/utils/mount/nfsmount.conf.man
> >> new file mode 100644
> >> index 0000000..1a3bb68
> >> --- /dev/null
> >> +++ b/utils/mount/nfsmount.conf.man
> >> @@ -0,0 +1,87 @@
> >> +.\"@(#)nfsmount.conf.5"
> >> +.TH NFSMOUNT.CONF 5 "9 Mar 2008"
> >> +.SH NAME
> >> +nfsmount.conf - Configuration file for NFS mounts
> >> +.SH SYNOPSIS
> >> +Configuration file for NFS mounts that allows options
> >> +to be set globally, per server or per mount point.
> >> +.SH DESCRIPTION
> >> +The configuration file is made up of multiple sections 
> >> +followed by variables associated with that section.
> >> +A section is defined by a string enclosed by 
> >> +.BR [
> >> +and 
> >> +.BR ]
> >> +branches; for example, 
> >> +.BR [nfsserver.foo.com] . 
> >> +Variables are assignment statements that assign values 
> >> +to particular variables using the  
> >> +.BR = 
> >> +operator, as in 
> >> +.BR Proto=Tcp .
> >> +Sections are broken up into three basic categories:
> >> +Global options, Server options and Mount Point options.
> >> +.HP
> >> +.BR [NFSMount_Global_Options]
> >> +- This statically named section
> >> +defines all of the global mount options that can be 
> >> +applied to every NFS mount.
> >> +.HP
> >> +.BR [<Server_Name>]
> > 
> > 
> > I notice the git configuration file uses a similar format, but allows
> > section headers that looks like:
> > 
> > 	[remote "origin"]
> > 	        url =
> > 		git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
> > 		fetch = +refs/heads/*:refs/remotes/origin/*
> > 	[remote "linux-nfs"]
> > 	        url = ssh://linux-nfs.org/~bfields/exports/linux.git
> > 		fetch = +refs/heads/*:refs/remotes/linux-nfs/*
> > 
> > That quoted part in the section name looks like it should allow
> > arbitrary strings without the risk of clashing with section names that
> > we might want to add in the future.  That might be a better way to
> > handle server and mount point names?
> 
> Something similar to [Server "server_name"] or [MountPoint "directory" ] ??

Right.

--b.
