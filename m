From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: problems with lockd in 2.6.22.6
Date: Sat, 8 Sep 2007 03:01:06 +0200
Message-ID: <200709080301.06969.wolfgang.walter@studentenwerk.mhn.de>
References: <200709071749.55760.wolfgang.walter@studentenwerk.mhn.de>
	<20070907203911.GA7706@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IToh8-0007Tn-Ov
	for nfs@lists.sourceforge.net; Fri, 07 Sep 2007 18:01:06 -0700
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]
	helo=email.studentenwerk.mhn.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ITohB-0001V9-RE
	for nfs@lists.sourceforge.net; Fri, 07 Sep 2007 18:01:11 -0700
In-Reply-To: <20070907203911.GA7706@uio.no>
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

On Friday 07 September 2007, Steinar H. Gunderson wrote:
> On Fri, Sep 07, 2007 at 05:49:55PM +0200, Wolfgang Walter wrote:
> > 2) The number of nfsd threads we are running on the machine is 1024. So =

this is not
> > the problem.
> =

> Wow, 1024? How many clients do you have? I'd normally assume 16 or 32 or
> something was a reasonable value...
> =


We have about 200 clients.

When we installed it several years ago (with kernel 2.4 and with udp) I =

doubled the number of threads every two weeks till there were no stalls =

(client side) in the morning any more. This was with 512 threads. I didn't =

notice any disadvantages, so I doubled it again.

When switching to 2.6 and tcp I just left it unchanged.

Regards,
-- =

Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
