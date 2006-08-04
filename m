From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
 draft-ietf-nfsv4-acls-00 not ready
Date: Fri, 04 Aug 2006 14:20:43 -0600
Message-ID: <2CC88068-A397-4DEB-8927-606C0A410D2C@Sun.COM>
References: <C98692FD98048C41885E0B0FACD9DFB8023DF6B9@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@Sun.COM>,
	"Pawlowski,  Brian" <beepy@netapp.com>,
	Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G969z-00030O-Hk
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 13:20:43 -0700
Received: from brmea-mail-2.sun.com ([192.18.98.43])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G969w-00060b-GI
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 13:20:44 -0700
Received: from fe-amer-03.sun.com ([192.18.108.177])
	by brmea-mail-2.sun.com (8.13.6+Sun/8.12.9) with ESMTP id
	k74KKeOt013522
	for <nfs@lists.sourceforge.net>; Fri, 4 Aug 2006 14:20:40 -0600 (MDT)
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
	(Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
	id <0J3H00A01PEU4X00@mail-amer.sun.com>
	(original mail from Sam.Falkner@Sun.COM) for nfs@lists.sourceforge.net;
	Fri, 04 Aug 2006 14:20:40 -0600 (MDT)
In-reply-to: <C98692FD98048C41885E0B0FACD9DFB8023DF6B9@exnane01.hq.netapp.com>
To: "Noveck, Dave" <Dave.Noveck@netapp.com>
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

On Jul 21, 2006, at 9:10 AM, Noveck, Dave wrote:

>> The current ACL spec, in the minorversion1 draft and in the previous
>> ACL drafts, rigorously specifies mode/ACL interactions by specifying
>> algorithms.  Bruce had the comment that the spec read as though the
>> algorithm was mandatory.
>
> That was my reading.  Was that the intention or not?

It was, but note that there were many optional steps.  The problem  
we've since come to recognize is that there may be other algorithms  
that do the job, and we don't want to disallow that.

>> Rethinking, it would be preferable to have the ACL specification
>> specify requirements, and have the algorithms serve as examples.
>
> I think the requirements that the algorithms are intended to address,
> would be helpful in understanding, whether the algorithms are
> examples or are mandatory.

Agreed.

>> Or,
>> rewrite the sections as requirements, and release algorithms outside
>> the minorversion1 draft, possibly through one or more informational
>> RFCs.  This would shorten the minorversion1 draft, without
>> invalidating the existing semantics.
>
> I think this would complicate understanding and review.  Even if
> the algorithms are examples and not mandatory, I would imagine
> they would be helpful in understanding the requirements and their
> implications, and if they are helpful, they should be in the spec,
> with an indication that they are illustrative and not mandatory.

I agree.  How about this: we move the algorithms into an appendix of  
minorversion1.  The appendix will expressly state that the algorithms  
are illustrative.  By having them in an appendix, they will be  
available, as opposed to moving them toward a separate informational  
RFC.

>> We'll try to have an initial draft of the ACL parts of the
>> minorversion1 document on August 7.  I'll also add an issue to nfs4-
>> editor.org.
>
> Here's a couple of other things I've noted that you might consider
> while working in this area:
>
>     There is statement about not using additional mode bits beyond
>     the ones defined but there is a "MUST NOT" addressed to the world
>     in general.  I think the mandate should be for the server.  It  
> MUST
>     NOT return other bits on GETATTR and MUST return NFS4ERR_INVAL if
>     other bits are set on SETATTR or CREATE/OPEN-create.  The  
> client is
>     free to use whatever bits he wants.  He is not disobeying the
> protocol
>     but he will get NFS4ERR_INVAL.

Done.

>     I don't see the point of allowing multiple behaviors in the  
> case in
>     which both MODE and ACL are set.  Rather than rell the client  
> how to
>
>     deal with all possible server behaviors, consider mandating the
> order
>     in which a SETATTR/CREATE with both MODE and ACL will be processed
> by
>     the server.  I think that would make life simpler for everybody.
> The
>     server knows what order he should do these in and the client knows
>     which order the changes will be done in.

Done.  Yes, this is much simpler.

* * *

Okay, here's the revised text.

http://www.nfsv4-editor.org/cgi-bin/roundup/nfsv4/file29/acls.txt

Please forgive the fact that the appendix appears as "Section 3"; it  
will eventually land in a proper appendix.

Regarding Spencer's question from before, about "ACL compatibility  
goals for NFSv4.1", this revised chapter qualifies as additional  
explanatory text.  Nothing is broken from RFC 3530, only clarified.   
Nothing new is proposed.  To my knowledge, the clients and servers  
that have been tested at the various Connectathon and Bakeathon  
events are fine with this spec.

- Sam

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
