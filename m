From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: NFS TCP settings
Date: Wed, 21 Dec 2005 11:02:21 -0800
Message-ID: <1135191742.1122.402.camel@seki.nac.uci.edu>
References: <20051221163254.70779.qmail@web34105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net, strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ep9EZ-0004eB-2k
	for nfs@lists.sourceforge.net; Wed, 21 Dec 2005 11:02:43 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Ep9EY-00008m-Tx
	for nfs@lists.sourceforge.net; Wed, 21 Dec 2005 11:02:43 -0800
To: Kenny Simpson <theonetruekenny@yahoo.com>
In-Reply-To: <20051221163254.70779.qmail@web34105.mail.mud.yahoo.com>
Sender: nfs-admin@lists.sourceforge.net
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

On Wed, 2005-12-21 at 08:32 -0800, Kenny Simpson wrote:
> --- Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > The NFS/RPC code has no direct control over the TCP window size. That
> > would be an issue for the networking people.
> 
> I have tracked this a bit further, and am reporting back for completeness..
> 
> The version of OnTap we are using (6.4.1p1) does not seem to support RFC 1323 (large TCP windows),
> but the Linux client does.  The window scaling is communicated in the initial connection (SYN), so
> if ethereal does not catch that, it will incorrectly report the window size as the unscaled number
> - making the Linux client appear to be using a very small window.
> The reason it appeared that the small window size was being honored is a result of the direct
> crossover cable making the BDP (bandwidth-delay product) very small.
> 
> As for the server side, because large TCP windows are not supported, the best it can do is 64k -
> which it does.  Running with GbE and jumbo packets fills the window quite fast obviating the need
> for RFC 1323.
> 
> Thanks to those who took the time to swing a clue stick in my direction.

Speaking of TCP Window Scaling...  :)

I have some connection between some pairs of hosts for which all of the
following appear to be true:

1) TCP Window Scaling is enabled on both endpoints
2) TCP Window Scaling is mentioned in the initial SYN and SYN/ACK
3) tcptrace thinks that TCP Window Scaling isn't happening

Is there something other than the SYN and SYN/ACK that might cause TCP
Window Scaling to go away?

(Other than SACK that is - we have that enabled - at least according to
tcptrace)

Thanks!




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
