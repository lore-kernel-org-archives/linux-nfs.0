Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Fri, 4 Sep 2009 15:13:14 -0400
Message-ID: <4d569c330909041213j213aad0bl52371fbffa346e6d@mail.gmail.com>
Subject: nfs-utils: Status of authenticated callback patches
From: Kevin Coffman <kwc@citi.umich.edu>
To: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
        NFS list <linux-nfs@vger.kernel.org>
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

This series of patches adds support for authenticated callbacks:

    http://markmail.org/thread/ikbfwcoomq5erjdy

The new functionality requires that both NFS servers and clients now
need to run both rpc.gssd and rpc.svcgssd.

I proposed that these two daemons be combined before distributions
changed their init scripts.  Unfortunately, I have not been able to
get to this, and don't anticipate I'll get to it in the near future.

I think Steve Dickson is waiting on this before committing the
previously mentioned series.  If anyone has time to devote to this,
that would be great!

I'll be glad to discuss some of the issues that I am aware of with
anyone looking to do this work.

K.C.
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
