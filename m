Return-Path: <nfsv4-bounces@linux-nfs.org>
Subject: RE: POSIX ACL support for NFSV4 (using sideband protocol)
From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
In-Reply-To: <7A24DF798E223B4C9864E8F92E8C93EC03F0ABED@SACMVEXC1-PRD.hq.netapp.com>
References: <7A24DF798E223B4C9864E8F92E8C93EC03F0ABED@SACMVEXC1-PRD.hq.netapp.com>
Date: Thu, 03 Sep 2009 11:01:59 -0400
Message-Id: <1251990119.4339.352.camel@moss-terrapins.epoch.ncsc.mil>
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

On Thu, 2009-09-03 at 00:46 -0700, Muntz, Daniel wrote:
> 
> ACLs could possibly be made completely opaque to NFS with a module-based
> approach.
> 
>   -Dan

Something to be aware of here is that once you turn a field opaque you
introduce a bunch of other issues. The MAC attribute that I've been
proposing in the IETF is mostly opaque and it has caused some problems
with interoperability. Some questions to be answered are

1) what is the initial set of modules defined? They aren't going to let
you take an opaque field and run away with it to do as you please. I've
been working on ways to define an initial set of label formats to make
the working group happier.

2) How are you going to specify these modules? It needs to be in a way
that implementors can easily use it. Are these specifications maintained
through the IETF or are they maintained by an outside organization?

3) How do modules translate between themselves. Are you going to only
allow like ACL modules to communicate? Will you have a mechanism for
those with ACL type A to still use a system with ACL type B? Will a
server be able to support both ACL type A and B? What happens if you
want both a Windows NFSv4 client and a Linux NFSv4 client to use the
same shares?

These are just some ideas to think about when you decide to make this
opaque.

Dave



_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
