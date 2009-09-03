From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
Date: Thu, 3 Sep 2009 09:55:16 -0400
Message-ID: <20090903135516.GB4566@fieldses.org>
References: <524f69650909021156lf181c17uf800eba7c35a6f45@mail.gmail.com>
	<20090902202206.GJ17884@fieldses.org>
	<524f69650909021353o1e055cbema16495c57cb9909b@mail.gmail.com>
	<4A9F6027.9050807@s3group.cz>
	<524f69650909030654u7653d410kd5cde25ec223a87@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	ffilzlnx@linux.vnet.ibm.com, jra@samba.org, agruen@suse.de
To: Steve French <smfrench@gmail.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <524f69650909030654u7653d410kd5cde25ec223a87@mail.gmail.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 03, 2009 at 08:54:06AM -0500, Steve French wrote:
> On Thu, Sep 3, 2009 at 1:20 AM, Ondrej Valousek<webserv@s3group.cz> wrote:
> >
> >> 2) If POSIX->NFSv4 client mapping is done (as had been suggested IIRC
> >> by others in the past) at least you lose less data (NFSv4 ACLs are
> >> "richer"
> >> in function than POSIX ACLs - so at least with the POSIX->NFSv4->POSIX
> >> case you are limiting the user to the subset of choices which are actually
> >> going to be able to be stored, no inheritence etc.)
> >>
> > I must say that I do not understand the motivation either. POSIX is not even
> > a standard and should be replaced with NFSv4 acls.
> > Even now ext3/ext4 support NFSv4 acls (ok. patch is needed but the patch is
> > there already).
> 
> If someone were able to convince the linux-fsdevel community to change
> fs/posix_acls.c
> (or add an fs/cifs_acls.c) to handle NFSv4/CIFS/NTFS ACL evaluation, and add
> support to store these richer ACLs on disk for the future (e.g. for
> btrfs), that would be
> great - but with no local file system in kernel which can store NFSv4 ACLs and
> no code to evaluate these ACLs in the VFS and with a NACK from fsdevel when

I don't remember that--do you have a pointer?

--b.

> others tried this a few years ago (even after MacOS and others moved to the
> CIFS/NTFS ACLs model)
> 
> > If the decision was up to me, I would forbid any nfsv4 acls if the server
> > can not store them properly (i.e. without any conversion)
> 
> That would be a pretty dramatic loss of function - being forced to use
> the primitive
> mode bits to protect files if the server were Linux - and could be
> worseeven NetApp does
> some ACL mapping
