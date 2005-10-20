From: Neil Brown <neilb@suse.de>
Subject: Re: Potential skew in /proc/net/rpc/nfsd
Date: Thu, 20 Oct 2005 10:38:30 +1000
Message-ID: <17238.59142.577880.266913@cse.unsw.edu.au>
References: <20051020001630.GL30673@anthem.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Christian Robottom Reis <kiko@async.com.br>
In-Reply-To: message from Christian Robottom Reis on Wednesday October 19
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

On Wednesday October 19, kiko@async.com.br wrote:
> 
> (Linux anthem 2.6.10-5-686-smp #1 SMP (Ubuntu Hoary))
> 
> Hello there,
> 
>     I've been studying the nfsd statistics file on our server, a
> dual-hyperthreaded-Xeon box (which appears to 2.6 as having 4 CPUs) and
> I've noticed an oddits in the thread statistics. Here's the output,
> edited to display clearly what I mean:
> 
>             th
>              8
>        2747936
>          59079.566
>          14835.486
>           5952.540
>              0.000
>           3293.329
>           2232.819
>           1900.259
>           1999.936
>              0.000
>           6549.737
> 
> Do the values of zero in the 4th and 9th percentage there make any
> sense, or are they an artifact of how the statistics are calculated
> (noting that I have 8 threads being used)?

An artifact of only having 8 threads.
The percentage of threads that can be in use with only 8 must be one of
0%, 12.5%, 25%, 37.5%, 50%, 62.5%, 75%, 87.5%, 100%

Note that none of those line in the [40-50) or [90-100) ranges.

> I've shifted the number of
> threads to 64 this morning, and this afternoon I now see:
> 
>             th
>             64
>        2748083
>          59543.017
>          14912.958
>           5959.034
>              0.854
>           3293.654
>           2233.022
>           1900.395
>           1999.936
>              0.000
>           6549.737
> 
> The 0.854 there in the 4th percentage suggests to me that the accounting
> is now functioning as it should; I might be mistaken, since it's the
> first time I look at these numbers, but that's what it suggests to
> me.

Yes.  It was always functioning as it should.  If you look at the
differences between the second set of number and the first, you should
see a sensible distributing.
It looks like you never get up to 80% of the 64 threads, so you were
never using more than about 50 threads in that time.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
