From: Daniel Hartmeier <daniel@benzedrine.cx>
Subject: Re: Re: pf: to scrub or not to scrub?
Date: Wed, 31 Jul 2002 15:54:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020731135402.GA25793@insomnia.benzedrine.cx>
References: <nfs-valinux.15684.6662.207461.819443@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from insomnia.benzedrine.cx ([62.65.145.30])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Ztva-0008UP-00
	for <nfs@lists.sourceforge.net>; Wed, 31 Jul 2002 06:54:15 -0700
Received: from insomnia.benzedrine.cx (dhartmei@localhost [127.0.0.1])
	by insomnia.benzedrine.cx (8.12.5/8.12.5) with ESMTP id g6VDs38r013528
	(version=TLSv1/SSLv3 cipher=EDH-DSS-DES-CBC3-SHA bits=168 verify=NO)
	for <nfs@lists.sourceforge.net>; Wed, 31 Jul 2002 15:54:03 +0200 (MEST)
Received: (from dhartmei@localhost)
	by insomnia.benzedrine.cx (8.12.5/8.12.5/Submit) id g6VDs2Mh002599
	for nfs@lists.sourceforge.net; Wed, 31 Jul 2002 15:54:03 +0200 (MEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <nfs-valinux.15684.6662.207461.819443@charged.uio.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On 2002-07-29 02:28:32 PST, Trond Myklebust wrote:

> Hmm... From your forwarded mail. Looks like they were saying that the
> firewall doesn't like IP_DF + IP_MF. That basically means that it is
> incompatible with standard Path MTU discovery (see RFC 1191).

Where does RFC 1191 (or Stevens, which I also checked) say you're
supposed to do PMTU discovery using _fragments_? You send complete,
unfragmented packets with DF set and see if you get an
ICMP_UNREACH_NEEDFRAG back. You mean a router gets already fragmented
packets (MF set) and then does PMTU to the destination itself, so the
fragments themselves don't get fragmented further? Or some host on the
way actually fragmented a DF packet? PMTU discovery explains the DF, but
who set the MF, assuming PMTU discovery is happening?

Daniel


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
