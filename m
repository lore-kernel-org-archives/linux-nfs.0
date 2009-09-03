Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Thu, 3 Sep 2009 16:11:46 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
Message-ID: <20090903104146.GA11784@skywalker.linux.vnet.ibm.com>
References: <4A9F6027.9050807@s3group.cz>
	<7A24DF798E223B4C9864E8F92E8C93EC03F0ABED@SACMVEXC1-PRD.hq.netapp.com>
In-Reply-To: <7A24DF798E223B4C9864E8F92E8C93EC03F0ABED@SACMVEXC1-PRD.hq.netapp.com>
Cc: linux-nfs@vger.kernel.org, "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        nfsv4@linux-nfs.org, ffilzlnx@linux.vnet.ibm.com,
        Steve French <smfrench@gmail.com>, jra@samba.org, agruen@suse.de
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 03, 2009 at 12:46:09AM -0700, Muntz, Daniel wrote:
> I've always thought of NFS as a means for making physical file systems
> available across a network.  NFS having its own ACLs doesn't fit this
> model.  E.g., "NFS ACLs" will never be integrated into NTFS.  However, I
> could imagine NFS ACLs solving the general problem if they were to form
> a superset of the ACLs of exportable physical file systems, and the
> mechanism for interpreting ACLs for a particular physical file system
> could be encoded (or modularized) in such a way that NFS' evaluation of
> ACL operations has the same results as the physical file system's
> execution of the same ACL operations.  You could have a POSIX ACL
> module, NTFS ACL module, etc.  There's a challenge for 4.2.
> 
> ACLs could possibly be made completely opaque to NFS with a module-based
> approach.
> 

What would be the acl model on the client side ? Considering that POSIX ACL
is looked at as the native acl model in Linux, I guess we should have the ability
to modify the ACLs using POSIX ACL tools on the nfs client

-aneesh
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
