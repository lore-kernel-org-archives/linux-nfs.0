From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
Date: Thu, 03 Sep 2009 10:09:28 -0400
Message-ID: <1251986968.18338.36.camel@heimdal.trondhjem.org>
References: <524f69650909021156lf181c17uf800eba7c35a6f45@mail.gmail.com>
	<20090902202206.GJ17884@fieldses.org>
	<524f69650909021353o1e055cbema16495c57cb9909b@mail.gmail.com>
	<4A9F6027.9050807@s3group.cz>
	<524f69650909030654u7653d410kd5cde25ec223a87@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: ffilzlnx@linux.vnet.ibm.com, linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	jra@samba.org, agruen@suse.de
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

On Thu, 2009-09-03 at 08:54 -0500, Steve French wrote:
> If someone were able to convince the linux-fsdevel community to change
> fs/posix_acls.c
> (or add an fs/cifs_acls.c) to handle NFSv4/CIFS/NTFS ACL evaluation, and add
> support to store these richer ACLs on disk for the future (e.g. for
> btrfs), that would be
> great - but with no local file system in kernel which can store NFSv4 ACLs and
> no code to evaluate these ACLs in the VFS and with a NACK from fsdevel when
> others tried this a few years ago (even after MacOS and others moved to the
> CIFS/NTFS ACLs model)

I don't think the fs-devel community is a problem. We have native
support for plenty of these filesystems which use alternative acl
models, so a very good case can be made for their inclusion.

The main problem has been finding developers with an interest, and with
enough time on their hands. Andreas Gruenbacher started working on NFSv4
acls, but due to his time constraints, his work ended up getting farmed
out to a developer in SGI, and consequently ended up in a black hole
somewhere...

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
