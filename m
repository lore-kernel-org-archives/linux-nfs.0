From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: Move (mv) hangs with NFSv4
Date: Mon, 14 Mar 2005 17:03:16 +0100
Message-ID: <4235B5C4.7060800@drzeus.cx>
References: <41B0A79A.2010203@drzeus.cx> <1102097931.10878.21.camel@lade.trondhjem.org> <20041207155227.GG31250@fieldses.org> <41B61C89.2060000@drzeus.cx> <20041207211715.GQ31250@fieldses.org> <41B6E933.4090708@drzeus.cx> <41D84216.9060504@drzeus.cx> <20050312185119.GA1064@fieldses.org> <42346C15.4080402@drzeus.cx> <20050313164804.GA10992@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAs2Q-0002Cv-5y
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 08:03:26 -0800
Received: from a26.t1.student.liu.se
	([130.236.221.26] helo=mail.drzeus.cx ident=daemon)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAs2O-00082H-Jq
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 08:03:26 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20050313164804.GA10992@fieldses.org>
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

J. Bruce Fields wrote:

>On Sun, Mar 13, 2005 at 05:36:37PM +0100, Pierre Ossman wrote:
>  
>
>>Ehm... where would these patches be located? I didn't see anything
>>obvious on the web page for any recent kernel. Or perhaps you meant the
>>lats nfs-utils? or both? =)
>>    
>>
>
>Sorry, I meant the latest citi kernel patch:
>
>http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/2.6.11-4/linux-2.6.11-CITI_NFS4_ALL-4.dif
>
>--b.
>  
>
I've tried the patch and the problem remains.

[root@apollo home]# ~/mv ~/freedesktop.org.xml .
Updating timestamps...done
Updating ownership...

(this is my hacked mv which lists each operation as it is performed)

Rgds
Pierre



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
