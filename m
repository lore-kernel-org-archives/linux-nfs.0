From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Strange behavior of executable bit
Date: Wed, 26 May 2004 05:25:55 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40B462A3.1070704@RedHat.com>
References: <40B44FE7.6010601@byggmek.lth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSufl-0002Z6-46
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 02:26:05 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BSufk-0003aV-K4
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 02:26:04 -0700
To: Jonas Lindemann <jonas.lindemann@byggmek.lth.se>
In-Reply-To: <40B44FE7.6010601@byggmek.lth.se>
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

Jonas Lindemann wrote:

> Running the following script:
>
> for i1 in 0 1 2 3 4 5 6 7 8 9 ; do
> for i2 in 0 1 2 3 4 5 6 7 8 9 ; do
> for i3 in 0 1 2 3 4 5 6 7 8 9 ; do
> ls -l "$joboption_directory/test.sh" 1>&2
> /bin/usleep 100000
> done
> done
> done
>
>
> Produce these results:
>
> And then it stabilizes.

I guess I'm  a bit confused... What are the expected results or
what do you mean by "stabilizes"?

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
