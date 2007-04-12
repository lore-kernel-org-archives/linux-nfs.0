From: David Liontooth <liontooth@cogweb.net>
Subject: Re: /etc/exports continue line
Date: Thu, 12 Apr 2007 15:10:16 -0700
Message-ID: <461EAE48.9020703@cogweb.net>
References: <461EA1CC.2050102@cogweb.net>
	<17950.42736.114011.686026@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc7Ue-0004nk-P8
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 15:10:17 -0700
Received: from smtp-3.smtp.ucla.edu ([169.232.48.136])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hc7Ug-00043e-1n
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 15:10:19 -0700
In-Reply-To: <17950.42736.114011.686026@notabene.brown>
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

Neil Brown wrote:
> On Thursday April 12, liontooth@cogweb.net wrote:
>   
>> I've been using \ to continue a line in /etc/exports, and ran into an
>> odd problem -- if you accidentally hit the TAB key after the continue
>> line and save, the entry becomes invalid. Since the TAB key is
>> invisible, it can be difficult to figure out what's going on.
>>
>> I reported it as Debian bug 418491 to nfs-kernel-server, and the
>> maintainer responded by saying \ isn't a valid continue character.
>> Comments? I routinely do this sort of thing:
>>
>> /spare \
>>         165.97.21.130(rw,no_root_squash,no_subtree_check,async) \
>>         165.97.21.132(rw,no_subtree_check,async) \
>>         165.97.21.133(rw,no_subtree_check,async) \
>>         165.97.21.134(rw,no_subtree_check,async) \
>>         165.97.21.135(rw,no_root_squash,no_subtree_check,async) \
>>         165.97.21.136(rw,no_subtree_check,async) \
>>         165.97.85.112(rw,no_subtree_check,async) \
>>         165.97.85.117(rw,no_subtree_check,async)
>>
>> A lot easier to maintain that a single line. Is there an alternative way
>> to continue the line?
>>     
>
> Use an editor that highlights spaces at the end of the line???
>
> But yes, I hate '\' line continuation too, for exactly that reason.
> The only alternative for /etc/exports is something like:
>
> /spare   165.97.21.130(rw,no_root_squash,no_subtree_check,async)
> /spare   165.97.21.132(rw,no_subtree_check,async)
> /spare   165.97.21.133(rw,no_subtree_check,async) 
> /spare   165.97.21.134(rw,no_subtree_check,async) 
> /spare   165.97.21.135(rw,no_root_squash,no_subtree_check,async) 
> /spare   165.97.21.136(rw,no_subtree_check,async) 
> /spare   165.97.85.112(rw,no_subtree_check,async)
> /spare   165.97.85.117(rw,no_subtree_check,async)
>
> NeilBrown
>   
Thank you for the suggestion; that would work, though I often cut and
paste chunks of lines from one exported drive listing to another.

Once you know about this quirk, it's obviously less of an issue. Still,
if I imagine trying to help myself in the past from this enlightened
position in the future, it would be fun to come up with a more
user-friendly solution. Could exportfs just filter out TAB characters,
or would you consider that unwanted code clutter?

Dave



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
