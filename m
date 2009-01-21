From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 15:23:47 -0500
Message-ID: <1232569427.7692.70.camel@heimdal.trondhjem.org>
References: <4970B451.4080201@RedHat.com>
	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>
	<497757D1.7090908@RedHat.com>
	<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
	<1232566140.7692.64.camel@heimdal.trondhjem.org>
	<49777E4C.2020501@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap@sources.redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <49777E4C.2020501@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-01-21 at 14:58 -0500, Steve Dickson wrote:
> Do we want to trace points:
>     1) at all 
>     2) for debugging 
>     3) for performance
>     4) 2 and 3
> 
> Once we get the above nailed down then we can decide how to go...

I think it might be a good idea to flesh out a bit what you mean by
"debugging" here. Since you mentioned it in conjunction with the two
words "administrators" and "scripts", I assume that you are not talking
about kernel code debugging?

Cheers
  Trond
