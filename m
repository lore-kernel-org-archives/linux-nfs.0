From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: Move (mv) hangs with NFSv4
Date: Sun, 13 Mar 2005 17:36:37 +0100
Message-ID: <42346C15.4080402@drzeus.cx>
References: <41B0A79A.2010203@drzeus.cx> <1102097931.10878.21.camel@lade.trondhjem.org> <20041207155227.GG31250@fieldses.org> <41B61C89.2060000@drzeus.cx> <20041207211715.GQ31250@fieldses.org> <41B6E933.4090708@drzeus.cx> <41D84216.9060504@drzeus.cx> <20050312185119.GA1064@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAW5F-0002Mf-6s
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 08:36:53 -0800
Received: from a26.t1.student.liu.se
	([130.236.221.26] helo=mail.drzeus.cx ident=daemon)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAW5B-0003oR-Hk
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 08:36:53 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20050312185119.GA1064@fieldses.org>
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

>On Sun, Jan 02, 2005 at 07:48:54PM +0100, Pierre Ossman wrote:
>  
>
>>>J. Bruce Fields wrote:
>>>      
>>>
>>>>Thanks.  It's a problem with the idmapping on the server, argh.  Is
>>>>rpc.idmapd still running after this, or does it die?--b.
>>>>
>>>>
>>>>        
>>>>
>>>It's still running. The effect is only local to the mv process. Other 
>>>traffic to the same mount continue to work perfectly.  There has been a 
>>>few incidents where the entire mount hangs. But in these cases I have to 
>>>restart the client, not the server.
>>>
>>>Can I get some debug output from idmapd that will pinpoint where the 
>>>problem is?
>>>
>>>      
>>>
>>Any updates to this issue?
>>    
>>
>
>Sorry for the overly long delay on the response.  Cleaning out my inbox
>prompted me to look back at this issue.  I did find one bug in the ACL
>code which could cause a "mv" with the target on an NFSv4 partition to
>fail.  Other than that I can't reproduce any problems with move.
>
>It's possible we've fixed something since the beginning of the year, or
>it's possible something else is going on.  If you get the chance to
>retest with our latest patches, let me know.
>
>--b.
>  
>

Ehm... where would these patches be located? I didn't see anything
obvious on the web page for any recent kernel. Or perhaps you meant the
lats nfs-utils? or both? =)

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
