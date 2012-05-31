Return-Path: linux-nfs-owner@vger.kernel.org
Received: from isrv.corpit.ru ([86.62.121.231]:41273 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757409Ab2EaNvV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 09:51:21 -0400
Message-ID: <4FC77755.5060606@msgid.tls.msk.ru>
Date: Thu, 31 May 2012 17:51:17 +0400
From: Michael Tokarev <mjt@tls.msk.ru>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: 3.0+ NFS issues
References: <4FBF2C57.3070203@msgid.tls.msk.ru>   <20120529152416.GC3441@fieldses.org> <4FC5C82E.4020806@msgid.tls.msk.ru>   <20120530132518.GA13794@fieldses.org> <4FC713ED.5040807@msgid.tls.msk.ru>  <1338469169.2420.7.camel@lade.trondhjem.org>  <4FC77128.9090206@msgid.tls.msk.ru> <1338471975.7732.5.camel@lade.trondhjem.org>
In-Reply-To: <1338471975.7732.5.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 31.05.2012 17:46, Myklebust, Trond wrote:
> On Thu, 2012-05-31 at 17:24 +0400, Michael Tokarev wrote:
[]
>> I started tcpdump:
>>
>>  tcpdump -npvi br0 -s 0 host 192.168.88.4 and \( proto ICMP or port 2049 \) -w nfsdump
>>
>> on the client (192.168.88.2).  Next I mounted a directory on the client,
>> and started reading (tar'ing) a directory into /dev/null.  It captured a
>> few stalls.  Tcpdump shows number of packets it got, the stalls are at
>> packet counts 58090, 97069 and 97071.  I cancelled the capture after that.
>>
>> The resulting file is available at http://www.corpit.ru/mjt/tmp/nfsdump.xz ,
>> it is 220Mb uncompressed and 1.3Mb compressed.  The source files are
>> 10 files of 1Gb each, all made by using `truncate' utility, so does not
>> take place on disk at all.  This also makes it obvious that the issue
>> does not depend on the speed of disk on the server (since in this case,
>> the server disk isn't even in use).
> 
> OK. So from the above file it looks as if the traffic is mainly READ
> requests.

The issue here happens only with reads.

> In 2 places the server stops responding. In both cases, the client seems
> to be sending a single TCP frame containing several COMPOUNDS containing
> READ requests (which should be legal) just prior to the hang. When the
> server doesn't respond, the client pings it with a RENEW, before it ends
> up severing the TCP connection and then retransmitting.

And sometimes -- speaking only from the behavour I've seen, not from the
actual frames sent -- server does not respond to the RENEW too, in which
case the client reports "nfs server no responding", and on the next
renew it may actually respond.  This happens too, but much more rare.

During these stalls, ie, when there's no network activity at all,
the server NFSD threads are busy eating all available CPU.

What does it all tell us? :)

Thank you!

/mjt
