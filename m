Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42021 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932180AbaG3SVC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jul 2014 14:21:02 -0400
Date: Wed, 30 Jul 2014 14:21:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "McEvoy, James" <james.mcevoy@hp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Fernandez, Roselle N" <roselle.fernandez@hp.com>,
        "Palanisamy, Nandesh" <nandesh.palanisamy@hp.com>
Subject: Re: NFSv4.1 ACL reference implementation
Message-ID: <20140730182101.GJ26316@fieldses.org>
References: <6301806E96421841896741228C6B1A2764A7C51F@G4W3216.americas.hpqcorp.net>
 <20140729210901.GA24471@fieldses.org>
 <6301806E96421841896741228C6B1A2764A7DCF7@G4W3216.americas.hpqcorp.net>
 <20140730180552.GI26316@fieldses.org>
 <6301806E96421841896741228C6B1A2764A7DEB1@G4W3216.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6301806E96421841896741228C6B1A2764A7DEB1@G4W3216.americas.hpqcorp.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 30, 2014 at 06:15:37PM +0000, McEvoy, James wrote:
> 
> 
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> > Sent: Wednesday, July 30, 2014 11:06 AM
> > To: McEvoy, James
> > Cc: linux-nfs@vger.kernel.org
> > Subject: Re: NFSv4.1 ACL reference implementation
> > 
> > On Wed, Jul 30, 2014 at 05:08:25PM +0000, McEvoy, James wrote:
> > > We are implementing NFSv4.1 ACLs in the filesystem mostly to support
> > > SMB/CIFS but I am seeing some strange behavior with ACL group
> > > inheritance on children/grand-children using the nfs4_setfacl and
> > > nfs4_getfacl on the parent directory.  The problems are mostly with
> > > inheritance on the @OWNER and @GROUP ACEs...
> > 
> > The usual problem is that the umask is applied.
> 
> Where can I find the proper behavior between umask and inheritance? 

For "posix" ACLs on local linux filesystems, the umask is just ignored
in the case where we're creating a new file in a directory with
default (inheritable) ACLs.

In the v4 case that doesn't happen.  I think this probably a bug that
needs to be fixed, but I'm not sure how.

--b.

> > > What I am looking for is a reference that I can use to validate ACL
> > > inheritance behavior. Is there a distro that has a filesystem which
> > > supports
> > > NFSv4 ACLs?  Or ideally an rpm that I could install on a CentOS6 VM.
> > > I have tried using the richacl mount option on OpenSUSE 13.1 but the
> > > nfs4_getfacl command returns:
> > > "Operation to request attribute not supported."
> > > The fstab entry to mount the filesystem is:
> > > /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-0-part3 \
> > > 	/home	ext4	acl,richacl,user_xattr 1 2
> > >
> > > Do you have any recommendations as to what and how I can install a
> > > filesystem that supports nfsv4 ACLs?
> > 
> > No, they all just do "posix" acls and nfsd tries to translate.
> > 
> > But the umask issue is somewhat of a separate issue.
> > 
> > --b.
> > 
> > >
> > >   --jim
> > >
> > > > -----Original Message-----
> > > > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > > > owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> > > > Sent: Tuesday, July 29, 2014 2:09 PM
> > > > To: McEvoy, James
> > > > Cc: linux-nfs@vger.kernel.org
> > > > Subject: Re: NFSv4.1 ACL reference implementation
> > > >
> > > > On Tue, Jul 29, 2014 at 07:18:03PM +0000, McEvoy, James wrote:
> > > > > Is there a working NFSv4.1 reference implementation available and
> > > > > are there
> > > > any instructs on how to build/install it?
> > > >
> > > > I don't recall seeing any, no.
> > > >
> > > > (Most NFSv4.0 ACL implementations should still be perfectly
> > > > compliant with the
> > > > NFSv4.1 spec too as far as I know.  But I don't know of any
> > > > implementations of the ACL features that are new to RFC 5661.  Is
> > > > there any particular feature that you're interested in?)
> > > >
> > > > --b.
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> > > > in the body of a message to majordomo@vger.kernel.org More majordomo
> > > > info at http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of
> > a message to majordomo@vger.kernel.org More majordomo info at
> > http://vger.kernel.org/majordomo-info.html
