From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Sat, 01 May 2004 23:19:14 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <409468B2.40200@RedHat.com>
References: <40892507.2030004@RedHat.com>  <4093CCB6.1040500@RedHat.com>	 <1083439518.3687.19.camel@lade.trondhjem.org> <4094397C.3030303@RedHat.com> <1083457337.3687.60.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BK7Vg-0002N5-7g
	for nfs@lists.sourceforge.net; Sat, 01 May 2004 20:19:20 -0700
Received: from mx2.redhat.com ([66.187.237.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BK7Vf-0004Gi-U9
	for nfs@lists.sourceforge.net; Sat, 01 May 2004 20:19:19 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1083457337.3687.60.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>So please tell me why the following patch (which addresses the
>particular problem that you raised of someone resetting mtime on the
>parent directory) does not suffice?
>  
>
Again this is were I started... and this patch does take care of the ESTALEs
but it also increases normal traffic by 2% to 3% (mostly getattrs and 
lookups)
when I ran the connectathon04 tests... Granted 2% to 3% is not that much
of an increase and my testing is not that exact... but....  any increase 
for an
error that generally does not happen, I didn't think would be acceptable...

But if this the patch thats going to make it into the 2.4 tree... so be 
it....
since it does avoid the ESTALE issues and maybe things will be a bit
more coherent since we do send a few more getattrs and lookups...

Thanks for your guidance.... it is definitely appreciated!

SteveD.




-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
