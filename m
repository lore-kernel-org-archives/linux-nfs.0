From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH/RFC 1/2] rpcproxyd
Date: Mon, 14 Mar 2005 11:52:49 +0100
Message-ID: <20050314105249.GH14815@suse.de>
References: <37086.66.11.176.22.1110228763.squirrel@webmail1.hrnoc.net> <37093.66.11.176.22.1110228819.squirrel@webmail1.hrnoc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <nfs@lists.sourceforge.net>,
	autofs mailing list <autofs@linux.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAnC0-0005PR-7d
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 02:53:00 -0800
Received: from mail-ex.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DAnBy-0001Dr-JK
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 02:53:00 -0800
To: mike@waychison.com
In-Reply-To: <37093.66.11.176.22.1110228819.squirrel@webmail1.hrnoc.net>
Sender: nfs-admin@lists.sourceforge.net
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

Hi Mike,

I'm somewhat wary of this idea, because it creates a very attractive
target for crackers. Once an attacker managers to fool this proxy
daemon, he can talk to your NFS Server, concealing his identity or
even posing as root, etc.

I looked at the code in the light of this, and there are a few
soft spots.

 -	you retrieve credentials in the initial negotiation
 	only. But client credentials can change, and should be
	checked with every packet.

	For instance, I can connect to your service, and fork off
	some setuid root application, with stderr connected to that
	socket. Any error message the application prints will be arrive
	with uid 0. If I manage to make that message appear valid to you,
	your daemon will accept any future input unquestioned.

	So my recommendation would be to validate credentials on
	every packet, and if they change from the original values
	received during negotiation, drop the connection.

	I'd also recommend to change the permissions on the Unix
	socket to 700.

 -	This mechanism is really a special-case workaround for the
 	mount problem, but you're creating a general purpose framework.
	That means if it's attacked successfully, it can be abused 
	to attack any RPC based service on any host.

	If you make it less generic, and allow only mount calls, you'll
	be much safer, because in the case of a bug, an attacker will
	be able to send fake MOUNT packets, but nothing else.

 -	In several places, you keep packet offsets (pos, bufferpos)
	in signed variables and compare them to unsigneds; that's
	dangerous.

 -	Your code assumes sizeof(unsigned long) == 4, eg here

	unsigned long len;
	[...]
		memcpy(&len, conn->buffer, 4);
		len = ntohl(len);
		buf = &conn->buffer[4];

	It's better to use uint32_t in such cases.

Regards,
Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
