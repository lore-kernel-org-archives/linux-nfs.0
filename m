From: Philippe =?ISO-8859-15?Q?Gramoull=E9?= <philippe.gramoulle@mmania.com>
Subject: Re: performance question
Date: Tue, 1 Apr 2003 18:06:33 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030401180633.05170a7d.philippe.gramoulle@mmania.com>
References: <1049188686.19334.20.camel@deskpro02>
	<20030401153950.27556.qmail@pour.midcoast.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp-103.nerim.net ([62.4.16.103] helo=kraid.nerim.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 190OHe-0001SX-00
	for <nfs@lists.sourceforge.net>; Tue, 01 Apr 2003 08:06:46 -0800
Received: from philou.gramoulle.local (pgramoul.net2.nerim.net [80.65.227.234])
	by kraid.nerim.net (Postfix) with SMTP id AA02A40F2D
	for <nfs@lists.sourceforge.net>; Tue,  1 Apr 2003 18:06:42 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

Hi,

Unless you're using an old exotic Cisco switch, i don't think you should do=
 this, IMHO.

We've had the worst problems doing that and since we use autoneg ( with int=
el EEpro100 card)
we never had a single problem ever since.

Thanks,

Philippe

--

Philippe Gramoull=E9
philippe.gramoulle@mmania.com
Lycos Europe - NOC France




On Tue, 1 Apr 2003 10:39:50 -0500 (EST)
jp@pour.midcoast.com wrote:

  | I always hard-set ethernet=20
  |  settings because I don't trust autonegotiation under all circumstances.


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
