From: Philippe =?ISO-8859-15?Q?Gramoull=E9?= <philippe.gramoulle@mmania.com>
Subject: Re: performance question
Date: Tue, 1 Apr 2003 19:08:01 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030401190801.53a516d0.philippe.gramoulle@mmania.com>
References: <1049188686.19334.20.camel@deskpro02>
	<20030401153950.27556.qmail@pour.midcoast.com>
	<20030401180633.05170a7d.philippe.gramoulle@mmania.com>
	<35ff01c2f86a$da9c1880$6601a8c0@userl3x55qxqed>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp-101.noc.nerim.net ([62.4.17.101] helo=mallaury.noc.nerim.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 190PF8-0006UG-00
	for <nfs@lists.sourceforge.net>; Tue, 01 Apr 2003 09:08:14 -0800
To: "Matt Heaton" <admin@0catch.com>
In-Reply-To: <35ff01c2f86a$da9c1880$6601a8c0@userl3x55qxqed>
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

Ok, i should have been more precise :)

My recommandations were only for NIC <-> switch.

In case of switch <-> switch then you could indeed force things without
problems.

I was refering to some Linux NFS servers, here,  having big troubles talkin=
g to=20
a switch (sorry i don't remember the brand) on which settings were forced.

Thanks,

Philippe

--

Philippe Gramoull=E9
philippe.gramoulle@mmania.com
Lycos Europe - NOC France



On Tue, 1 Apr 2003 09:22:13 -0700
"Matt Heaton" <admin@0catch.com> wrote:

  | I just have to respond to this.  I must respectfully disagree.
  | Autonegotiation is tolerable at best.
  | With certain equiptment it works flawlessly, but MANY brands autonegoti=
ate
  | correct speeds and duplex, but still exhibit 2-3% packetloss or intermi=
ttant
  | latency (high pings times etc).  A perfect example is my cisco 2940 cat=
alyst
  | switch and my alteon/nortel 180e (layer 2-7 switch).  Both switches are=
 high
  | quality and work well, but if you link them up with autonegiation you w=
ill
  | have problems.  It will detect proper speeds and duplex, but has speed
  | problems and packet loss.  When contacting BOTH cisco and nortel support
  | they both said autonegiation is bad news and should be used only to get
  | things up and going.  Cisco said if all the products were cisco then no
  | problem, just as nortel said the same thing.  Just my 2 cents worth, bu=
t I
  | have seen this problem on more than 5 devices on my own network alone.
  |=20
  | L8r...
  |=20
  | Matt
  |=20
  | ----- Original Message -----
  | From: "Philippe Gramoull=E9" <philippe.gramoulle@mmania.com>
  | To: <nfs@lists.sourceforge.net>
  | Sent: Tuesday, April 01, 2003 9:06 AM
  | Subject: Re: [NFS] performance question
  |=20
  |=20
  | Hi,
  |=20
  | Unless you're using an old exotic Cisco switch, i don't think you shoul=
d do
  | this, IMHO.
  |=20
  | We've had the worst problems doing that and since we use autoneg ( with
  | intel EEpro100 card)
  | we never had a single problem ever since.
  |=20
  | Thanks,
  |=20
  | Philippe
  |=20
  | --
  |=20
  | Philippe Gramoull=E9
  | philippe.gramoulle@mmania.com
  | Lycos Europe - NOC France
  |=20
  |=20
  |=20
  |=20
  | On Tue, 1 Apr 2003 10:39:50 -0500 (EST)
  | jp@pour.midcoast.com wrote:
  |=20
  |   | I always hard-set ethernet
  |   |  settings because I don't trust autonegotiation under all circumsta=
nces.
  |=20
  |=20
  | -------------------------------------------------------
  | This SF.net email is sponsored by: ValueWeb:
  | Dedicated Hosting for just $79/mo with 500 GB of bandwidth!
  | No other company gives more support or power for your dedicated server
  | http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
  | _______________________________________________
  | NFS maillist  -  NFS@lists.sourceforge.net
  | https://lists.sourceforge.net/lists/listinfo/nfs
  |=20
  |=20
  |=20
  |=20
  | -------------------------------------------------------
  | This SF.net email is sponsored by: ValueWeb:=20
  | Dedicated Hosting for just $79/mo with 500 GB of bandwidth!=20
  | No other company gives more support or power for your dedicated server
  | http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
  | _______________________________________________
  | NFS maillist  -  NFS@lists.sourceforge.net
  | https://lists.sourceforge.net/lists/listinfo/nfs
  |=20


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
