From: "Guolin Cheng" <guolin@alexa.com>
Subject: Poor Fedora Core 1's NFS performance and how to tune it?
Date: Fri, 16 Apr 2004 15:52:41 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41089CB27BD8D24E8385C8003EDAF7AB08485A@karl.alexa.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "ops" <ops@alexa.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BEcCg-0002YT-28
	for nfs@lists.sourceforge.net; Fri, 16 Apr 2004 15:52:58 -0700
Received: from birdwell-public.alexa.com ([67.107.182.10] helo=karl.presidio.alexa.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BEcCf-0001dU-S2
	for nfs@lists.sourceforge.net; Fri, 16 Apr 2004 15:52:57 -0700
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,

 We installed about tens of Fedora Core 1 machines, But then found that
the FC1 NFS speed is greatly slow down contrasted with our previous
Redhat 8.0.
Our FC1's nfs speed is now at 6MB/s, while original Redhat 8.0's speed
is at 10MB/s. For both operation systems I did no special NFS tunings.

Our Original environment RH8 environment is:  Redhat 8.0, 2.4.20 vanilla
kernel without "nfs over tcp" support.

Our current environment is: Fedora Core 1, 2.4.25 vanilla kernel, with
"nfs over tcp" kernel support enabled.

But it seems that the nfs performance has no directly relationship with
"nfs over tcp" in kernel configuration. The reason is:=20

I use both RH8|FC1 clients to connect to FC1 nfs server, connections set
to either "nfs over udp" or "nfs over tcp", the speed is about the same,
ranged from 6.09MB/s to 6.30MB/s.

But from original RH8 nfs clients to RH8 nfs servers, the speed is at
10MB-11MB/s, since I compiled no "nfs over tcp" support for RH8 kernel,
the nfs connection is based on UDP traffic only.

Personally I prefer "nfs over tcp" feature enabled. Since tcp traffic is
more reliable and bring less trouble to Ops, even it is a little less
efficient.=20

I tried to increase the NFS read/write size from 1024/1024, to
4096/4096, to 8192/8192, but that makes almost no difference at all.

Any suggestions/opinions on why FC1's nfs performance is downgraded? Or
I need to adjust any other parameters?=20

Thanks.
--Guolin Cheng





-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
