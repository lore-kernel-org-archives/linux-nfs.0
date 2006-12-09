From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/2] mountd: clean up rmtab handling
Date: Sat, 09 Dec 2006 07:27:48 -0500
Message-ID: <457AABC4.3000805@redhat.com>
References: <1161781620.7078.50.camel@dantu.rdu.redhat.com>	<45704A4A.6000007@poochiereds.net>	<17779.42545.642976.873602@cse.unsw.edu.au>	<17779.49460.590066.210744@cse.unsw.edu.au>	<4574D964.8070504@redhat.com>
	<4574DEB9.1060004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gt1J6-0005HT-NU
	for nfs@lists.sourceforge.net; Sat, 09 Dec 2006 04:27:56 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gt1J6-0004B8-RV
	for nfs@lists.sourceforge.net; Sat, 09 Dec 2006 04:27:58 -0800
To: Jeff Layton <jlayton@redhat.com>
In-Reply-To: <4574DEB9.1060004@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Jeff Layton wrote:
>> How about this patch instead? It combines some of my earlier patches
>> with the one you just proposed.  I did some very cursory testing and it
>> seems to work correctly, populating rmtab with hostname:/path instead of
>> ipaddr:/path.
>>
> 
> Apologies, my mailer munged that last patch. Here it is again...
> 

Hi Neil. Any thoughts on the patch I sent out on Dec 4th?

Thanks,
Jeff

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
