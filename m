From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: Missing handling for
	NFS4ERR_OLD_STATEID	in	nfs4_handle_exception?
Date: Thu, 12 Apr 2007 13:51:16 -0400
Message-ID: <461E7194.2030500@poochiereds.net>
References: <1175616589.3531.8.camel@dyn9047022153>	
	<461E1F2C.7000605@poochiereds.net>
	<1176397862.3531.20.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>, nfsv4@linux-nfs.org
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc3S1-0003GY-4m
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 10:51:20 -0700
Received: from ms-smtp-01.southeast.rr.com ([24.25.9.100])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hc3S3-0005m9-DD
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 10:51:19 -0700
In-Reply-To: <1176397862.3531.20.camel@dyn9047022153>
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

Frank Filz wrote:
> On Thu, 2007-04-12 at 07:59 -0400, Jeff Layton wrote:
>> This looks pretty much correct to me as-is. If we set ret=0 on 
>> -NFS4ERR_OLD_STATEID, then the caller won't get back an error code. This 
>> makes an assumption that every caller of nfs4_handle_exception is 
>> looping based on exception->retry. I'm not sure if that's a safe 
>> assumption. A better idea *might* be to fix up nfs4_map_errors not to 
>> throw the warning for some errors < -1000, but still return an error.
> 
> nfs4_map_errors should warn about errors, because it's a last defense
> against leaking NFS4 error numbers to the rest of the kernel (that
> doesn't recognize them). So before calling nfs4_map_errors(), the error
> code should already be converted to an errno code.
> 
> It looked to me like every caller of nfs4_handle_exception() does loop
> on exception-retry(), and in that case, does not look at the error
> returned.
> 

Yes, that is the current case, but is it safe to assume that it will 
always be that way (I'm not sure, which is why I'm asking)?

I guess I'm not sure what the problem is that you're trying to solve. 
Are you simply attempting to avoid the printk's here? I'm not sure if 
that would be a good thing. I'd think if we're seeing a lot of these 
errors, then having the printk's might be good for helping to identify 
the problem. If there aren't many, then the printks seem fairly harmless...

-- Jeff


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
