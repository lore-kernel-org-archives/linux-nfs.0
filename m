From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: Re: mountd randomly crash and panic the server
Date: Mon, 16 Apr 2007 16:07:09 +0200
Message-ID: <4623830D.7040108@oxeva.fr>
References: <461CFABE.9050301@barazer.net>	<46234130.5020502@oxeva.fr>
	<17955.21572.383131.837268@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdRs3-00038z-0V
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 07:07:57 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HdRs4-0005Fb-1K
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 07:07:57 -0700
In-Reply-To: <17955.21572.383131.837268@notabene.brown>
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

On 04/16/2007 12:47:32 +0200, Neil Brown <neilb@suse.de> wrote:

> On Monday April 16, gabriel@oxeva.fr wrote:

>>
>> Is this related to the kernel cache_clean function in net/sunrpc/cache.c ?
> 
> Yes.  It is crashing at:
> 		for (; ch; cp= & ch->next, ch= *cp) {
> 			if (current_detail->nextcheck > ch->expiry_time)
>                                                         ^^^^^^
> 				current_detail->nextcheck = ch->expiry_time+1;
> 			if (ch->expiry_time >= get_seconds()
> 
> ch has a garbage value (0001e71926010009), presumable because a
> previous cp had been corrupted, most likely by being freed while still
> in use.
> 

Maybe this can helps : I never encountered the problem with kernel 
2.6.18, maybe this can restrict the scope for where is this corruption 
happening ?

> Bother.
> 
> I'll see if I can figure out what is happening.
> 
> Thanks for the report.
> 
> NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
