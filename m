From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: nfsd and kswapd
Date: Mon, 07 Jun 2004 13:19:39 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40C44F4B.9090307@inf.ethz.ch>
References: <004c01c44c78$5f789120$0200000a@CARTMAN>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXGpv-0008Mc-L4
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 02:54:35 -0700
Received: from xsmtp.ethz.ch ([129.132.97.6])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BXGpv-00020X-71
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 02:54:35 -0700
To: Amir Hermelin <amir@montilio.com>
In-Reply-To: <004c01c44c78$5f789120$0200000a@CARTMAN>
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

Hi Amir,

Amir Hermelin wrote:

>Thanks Marc for the info.  It so happens I'm also using a PowerEdge (2600),
>so I'll check out that thread.  I'm using a RH 9 system, kernel 2.4.20-8 -
>should that include the better mem management you've mentioned?
>  
>
Yes, but 2.4.20-8 is very old and does not have the kswapd fix. Try 
upgrading to 2.4.20-31 
(https://rhn.redhat.com/errata/RHSA-2004-166.html), it should make a 
difference.

Greetings,
    Marc


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
