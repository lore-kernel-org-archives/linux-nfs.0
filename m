From: Steve French <smfrench@gmail.com>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
Date: Thu, 3 Sep 2009 10:14:49 -0500
Message-ID: <524f69650909030814j6b253321mc4ab5fbbb2342b66@mail.gmail.com>
References: <524f69650909021156lf181c17uf800eba7c35a6f45@mail.gmail.com>
	<20090902202206.GJ17884@fieldses.org>
	<524f69650909021353o1e055cbema16495c57cb9909b@mail.gmail.com>
	<20090903141637.GC4566@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	ffilzlnx@linux.vnet.ibm.com, jra@samba.org, agruen@suse.de
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090903141637.GC4566@fieldses.org>
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

On Thu, Sep 3, 2009 at 9:16 AM, J. Bruce Fields<bfields@fieldses.org> wrote:
> If I remember correctly, Linux's posix acl support was added at about
> the same time the NFSv4.0 spec was being written--I seem to recall the
> first ACL patches being merged around the same time as the first NFSv4
> patches?

NFSv4 RFC was December 2000 (CIFS/NTFS ACLs, which were much more
complex than earlier OS/2 ACLs,  are about 4 years earlier than NFSv4
ACLs).   POSIX ACL support was added to mainline Linux kernel at the
end of 2002 (see below):

2002/10/31 02:34:21-05:00 tytso
Port of (bugfixed) 0.8.50 acl-ext2 to 2.5

This patch adds ACL support to the ext2 filesystem.

2002/10/31 02:33:05-05:00 tytso
Port of (bugfixed) 0.8.50 acl-ext3 to 2.5.

This patch adds ACL support to the ext3 filesystem.

2002/10/31 02:30:17-05:00 tytso
Port 0.8.50 acl-xattr patch to 2.5 (harmonize header file with SGI/XFS)

This patch provides converts extended attributes passed in from user
space to a generic Posix ACL representation.



-- 
Thanks,

Steve
