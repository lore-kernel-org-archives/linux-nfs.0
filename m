From: Neil Brown <neilb@suse.de>
Subject: Re: Autofs-mounted NFS directories disappearing
Date: Wed, 19 Oct 2005 13:04:57 +1000
Message-ID: <17237.47065.784615.356338@cse.unsw.edu.au>
References: <6.2.1.2.2.20051010141020.05b86a00@mail.enuclia.com>
	<17227.5560.451453.95349@cse.unsw.edu.au>
	<6.2.1.2.2.20051018132306.05b6f070@mail.enuclia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ES4GR-0001Eg-WA
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 20:05:15 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ES4GQ-0002Z3-LF
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 20:05:16 -0700
To: "John Medway, Enuclia Semiconductor" <john.medway@enuclia.com>
In-Reply-To: message from John Medway, Enuclia Semiconductor on Tuesday October 18
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

On Tuesday October 18, john.medway@enuclia.com wrote:
> Neil,
> 
> Made this change late last week, and while it seems to have fixed the 
> problem, now we're seeing a roughly daily out of memory kernel panic on the 
> machine, which did not happen beforehand. I can't say for sure they are 
> related, but they are, at least, coincidental. I'm going to revert the 
> change, to see if the panics stop.
> 
> I'm unfortunately semi-stuck with this kernel for the moment, so I was 
> wondering if there are other ideas I could try.

I'm afraid I cannot suggest anything else.
Being stuck with an old kernel is most unfortunate...

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
