From: "Gareth Glaccum" <verycoldpenguin@hotmail.com>
Subject: Re: NFS using too much memory on diskless system
Date: Thu, 24 Feb 2005 14:07:47 +0000
Message-ID: <BAY101-F142FE76E15914F506B731DBD640@phx.gbl>
References: <20050224131709.GA6093@ti64.telemetry-investments.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4Jf2-0007fK-4Z
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 06:08:12 -0800
Received: from bay101-f14.bay101.hotmail.com ([64.4.56.24] helo=hotmail.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D4Jf0-0002Wp-Ou
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 06:08:12 -0800
In-Reply-To: <20050224131709.GA6093@ti64.telemetry-investments.com>
To: nfs@lists.sourceforge.net
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

Thanks Bill, I shall investigate these patches as a possible permanent fix.
Gareth

>From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
> > Is there some way of limiting the NFS cache size like there used to be 
>in
> > the 2.4 kernel? (see section B7 of the nfs FAQ I believe)
>
>There was definitely a known issue with NFS write-throttling back in early 
>2.6.
>Andrew Morton had an "nfs-write-throttling.patch" in the -mm series for a 
>while;
>I'm not sure when it was merged.  Perhaps try a recent mainline kernel, or
>dig out the patch(es) and see whether they apply to your SuSE kernel.
>
>Regards,
>
>	Bill Rugolsky

_________________________________________________________________
Express yourself with cool new emoticons http://www.msn.co.uk/specials/myemo



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
