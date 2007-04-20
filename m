From: Jeff Layton <jlayton@redhat.com>
Subject: Re: svc_process and nfsd_proc_read not taking checksum into
 account when calling svc_reserve
Date: Fri, 20 Apr 2007 14:33:45 -0400
Message-ID: <46290789.7080908@redhat.com>
References: <4628D19F.5080805@redhat.com> <20070420174748.GG19285@fieldses.org>
	<4d569c330704201057l1ba2a131r39df22db6e917fb3@mail.gmail.com>
	<20070420181144.GI19285@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Kevin Coffman <kwc@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HexvX-0000HH-PR
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 11:33:48 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hexva-0001po-2S
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 11:33:50 -0700
In-Reply-To: <20070420181144.GI19285@fieldses.org>
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

J. Bruce Fields wrote:
> On Fri, Apr 20, 2007 at 01:57:55PM -0400, Kevin Coffman wrote:
>> On 4/20/07, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> You don't need to know the exact amount, just an upper bound, right?
>>>
>>> In which case I'd be tempted to just look at some krb5i and krb5p
>>> traffic in wireshark, figure out how much it adds (it should always be
>>> the same, except that krb5p pads the arguments to the nearest 8-byte
>>> boundary, which will add padding that varies between 1 and 8 bytes.)
>> Is the length going to depend on the Kerberos encryption-type as well?
> 
> Yep.  But for now we can just hard-code a constant that works for
> des-cbc-whatever-it-is, with a note that some day we should increase the
> constant or (if we really need it to be a tight bound on the length),
> replace it by a call to the gssapi code.
> 
> --b.

Thanks for the info. I'll shoot for just having the wrapper add a 
constant value to it for now (though I'll at least get the auth flavor 
and set that value to 0 for auth_null and auth_unix).

I tested krb5p and it seems to be off by 52 bytes, but I was using 
des-cbc-crc:normal. Got a suggestion of what kerberos enc type I should 
use to try to maximize the length?

Thanks,
Jeff



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
