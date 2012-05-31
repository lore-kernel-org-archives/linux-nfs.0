Return-Path: linux-nfs-owner@vger.kernel.org
Received: from isrv.corpit.ru ([86.62.121.231]:38519 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758036Ab2EaNZB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 09:25:01 -0400
Message-ID: <4FC77128.9090206@msgid.tls.msk.ru>
Date: Thu, 31 May 2012 17:24:56 +0400
From: Michael Tokarev <mjt@tls.msk.ru>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: 3.0+ NFS issues
References: <4FBF2C57.3070203@msgid.tls.msk.ru>  <20120529152416.GC3441@fieldses.org> <4FC5C82E.4020806@msgid.tls.msk.ru>  <20120530132518.GA13794@fieldses.org> <4FC713ED.5040807@msgid.tls.msk.ru> <1338469169.2420.7.camel@lade.trondhjem.org>
In-Reply-To: <1338469169.2420.7.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 31.05.2012 16:59, Myklebust, Trond wrote:
[]
> That is tcpdump trying to interpret your NFSv4 trace as NFSv2/v3.

Oh.

> Can you either please use wireshark to provide a full text dump (using
> something like 'tshark -V -O nfs,rpc'), or just send us the binary
> tcpdump output using 'tcpdump -w /tmp/foo -s 90000'?

I started tcpdump:

 tcpdump -npvi br0 -s 0 host 192.168.88.4 and \( proto ICMP or port 2049 \) -w nfsdump

on the client (192.168.88.2).  Next I mounted a directory on the client,
and started reading (tar'ing) a directory into /dev/null.  It captured a
few stalls.  Tcpdump shows number of packets it got, the stalls are at
packet counts 58090, 97069 and 97071.  I cancelled the capture after that.

The resulting file is available at http://www.corpit.ru/mjt/tmp/nfsdump.xz ,
it is 220Mb uncompressed and 1.3Mb compressed.  The source files are
10 files of 1Gb each, all made by using `truncate' utility, so does not
take place on disk at all.  This also makes it obvious that the issue
does not depend on the speed of disk on the server (since in this case,
the server disk isn't even in use).

What I noticed is: with default 8 NFSD threads, it takes quite a bit
longer to hit this issue, but it still happens.  The capture was
done using 2 threads.

>>>> Can at least the client be made interruptible?  Mounting with
>>>> -o intr,soft makes no visible difference...
>>
>> please? :)
> 
> It already is interruptible: try 'kill -9' or any other fatal signal.

Oh.  Indeed, I can kill it from another terminal using -9.  That is
great already!

Thank you!

/mjt
