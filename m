Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42902 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495Ab3CKR7S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 13:59:18 -0400
Date: Mon, 11 Mar 2013 13:59:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 11/11] gssd: Add "-c" command line option
Message-ID: <20130311175917.GB30618@fieldses.org>
References: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
 <20130308194741.5656.56599.stgit@seurat.1015granger.net>
 <20130311175833.GA30618@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130311175833.GA30618@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 11, 2013 at 01:58:33PM -0400, bfields wrote:
> On Fri, Mar 08, 2013 at 02:47:41PM -0500, Chuck Lever wrote:
> > When a system does not have a keytab, it has no way to obtain
> > machine credentials.  In the past, we've fudged it by simply using
> > root's user credential as the machine credential.  (root must kinit
> > in this case, of course).
> > 
> > Since v1 of the kernel's GSS upcall was introduced, rpc.gssd can
> > tell when the kernel requests a machine credential specifically,
> > say, for NFSv4 operations that are required to use one
> > (SETCLIENTID).
> > 
> > Since I moved SETCLIENTID to the first operation performed against
> > a new server, this means a sec=krb5 NFSv4 mount can't succeed at all
> > if there is no machine credential.  Previously, this kind of mount
> > could work at least until a SETCLIENTID was done, as the kernel
> > could use root's user credential for housekeeping like grabbing the
> > server's root FH.  (Or maybe there is some kind of gssd bug that
> > allowed it to keep working?).
> > 
> > In any event, what we want to do is provide a clean and secure way
> > for rpc.gssd to substitute a specific user credential if there is no
> > machine credential available.  (I'm actually not clear on why this
> > is OK to do).
> > 
> > Recent work to add Active Directory support to rpc.gssd gives us a
> > potential user principal that can be used for this purpose:
> > 
> >   HOSTNAME$@REALM
> > 
> > We have a specific user principal then.  We have to tell rpc.gssd
> > where to look for the credential file.  Introduce a command line
> > option that specifies exactly where the file containing the
> > credential for this principal can be found.  This credential would
> > be used only if no other machine credential is available.
> > 
> > One might then use it this way:
> > 
> >   # /usr/sbin/rpc.gssd -n -c /tmp/krb5cc_0
> >   # kinit <hostname>$@<REALM>
> >   Password for <hostname>$@<REALM>:
> >   # mount -t nfs4 -o sec=krb5 server:/export /mnt
> 
> Say my university gives me a kerberos identity bfields@example.edu and
> a home directory files.example.edu:/home/bfields.
> 
> Then previously I could access my home directory from my personal laptop
> with
> 
> 	# kinit bfields@umich.edu
> 	# mount -tnfs4 -osec=krb5 files.example.edu:/home/bfields /u-home
> 
> But now if I want to do that I have to talk example.u's IT department
> into issuing me bfields$@umich.edu?
> 
> If so, haven't we lost a useful feature?

(ACK to all the other patches.)

--b.
