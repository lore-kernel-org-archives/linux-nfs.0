From: Bob Kryger <bobk@panix.com>
Subject: Re: nfs write problems
Date: Wed, 03 Oct 2007 06:21:51 -0400
Message-ID: <47036D3F.8070904@panix.com>
References: <4702A279.3080001@panix.com>
	<1191370059.6707.38.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: For users of Fedora <fedora-list@redhat.com>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id1MZ-0002ac-8h
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 03:21:55 -0700
Received: from mail2.panix.com ([166.84.1.73])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Id1Mb-0005vV-C0
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 03:22:00 -0700
In-Reply-To: <1191370059.6707.38.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Trond Myklebust wrote:
> On Tue, 2007-10-02 at 15:56 -0400, Bob Kryger wrote:
>   
>> So, I have a relatively new system on which I am seeing strange NFS 
>> behavior.
>>
>> In short I am getting seemingly random errors in files written via NFS.
>>     
[snip details]
>> Anyone ever seen anything like this before?
>> Suggest where I might look next?
>> Additional tests?
>>     
>
> Feel free to describe your test in a bit more detail. Without more
> information, we obviously can't rule out the existence of an NFS bug,
>   
I was trying to be thorough, I hope I succeeded.

Is there anything else that might be helpful? I certainly would not go 
to a bug first, as I may very well have something misconfigured, but I 
cannot seem to identify what that might be. I do have about 8 other 
linux NFS servers in production on different hardware, SATA mostly, 
where I am not seeing any issues. I don't think it's a hardware issue 
though, as I cannot reproduce the problem without the use of NFS. (Hmm, 
maybe if I NFS mount to the server itself. Would that prove anything?)
> however usually whenever people describe this sort of problem it is
> because they have failed to understand the NFS caching model as
> described in
>
>     http://nfs.sourceforge.net/#faq_a8
>   
Excellent, Thanks for the lead and I will test these items shortly.

After reading the FAQ, I'm not sure I see how the cache consistency 
mechanisms apply to this problem. If I test the files after they are 
closed shouldn't the data be consistent, written completely to the 
server? If there were a data write error should I not see it somewhere? 
If so where? client? server? would it be up to the client program to 
catch it? I wonder if dd would see it. For the purpose of testing, I 
have limited this server to serving to only a single client at a time, 
so there will be no other variables/systems interfering.

So to test this I read back the data of a newly written, 256M file, 
right from the client that wrote it. In this case with nocto option. 
This should take the client cache into account. I compared the results 
from the server side as well. It had errors, the same errors in the same 
locations on both the client and the server. So, this seems to indicate 
that it is the issue is on the nfs client not the server. (hmmm) But the 
same client does not have a problem with any other server. At least one 
has never been reported. I'll verify that rigorously.

I am not familiar with the mechanism that NFS uses to verify data 
validity between the client and the server. I assume that there is some 
sort of checksum. Did I mention that this is NFSv3? At least I have not 
specified v4.
> So please include a reproducible test for us.
>   
Easily reproducible on this system. Short of providing access to this 
system, not sure what more to do. Oh, wait, was that humor? Indicating 
that I have provided significant detail? Dang, I've got to sharpen my 
international tongue-in-cheek detector.
> Cheers
>   Trond
>   
Cool name

thanks
Bob
>
>   


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
