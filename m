From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: performance question
Date: Tue, 1 Apr 2003 20:45:33 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0304012024410.4695-100000@kenzo.iwr.uni-heidelberg.de>
References: <20030401153950.27556.qmail@pour.midcoast.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: =?ISO-8859-1?Q?K=E5re?= Hviid <ukh@id.cbs.dk>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 190Qlh-0004lH-00
	for <nfs@lists.sourceforge.net>; Tue, 01 Apr 2003 10:45:57 -0800
To: jp@pour.midcoast.com
In-Reply-To: <20030401153950.27556.qmail@pour.midcoast.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, 1 Apr 2003 jp@pour.midcoast.com wrote:

> Flow control on the switch is disabled - the default, I checked. It's also 
> set for 100-FD, like my ethernet cards. I always hard-set ethernet 
> settings because I don't trust autonegotiation under all circumstances.

People that don't want to be helped should not ask for help any more!
I've already warned about forcing speed, check the net driver mailing 
lists and scyld.com to see why and also for some words from Donald Becker 
about why the forcing of speed and duplex ever came into discussion.

> WARNING: option -b implies udp testing

Oh yes, you want to test network quality with UDP... Have you ever thought 
that NFS needs communication both ways ? If you think that your network 
with forced full-duplex is perfect, try two UDP streams in opposite 
directions - you should not loose one packet and still achieve high 
bandwidth; and if you want to stress it even more, try UDP packets that do 
not fit in an Ethernet frame.

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
