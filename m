From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] lockd control of grace period for HA NFS
Date: Mon, 6 Dec 2004 10:04:28 -0500
Message-ID: <20041206150428.GC20864@fieldses.org>
References: <16802.32693.974799.504191@cse.unsw.edu.au> <OFB81726D4.627FD14C-ON88256F56.0010B138-88256F56.001402F0@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CbKPh-0005Rn-Hr
	for nfs@lists.sourceforge.net; Mon, 06 Dec 2004 07:04:33 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CbKPf-0000Kw-Rb
	for nfs@lists.sourceforge.net; Mon, 06 Dec 2004 07:04:32 -0800
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OFB81726D4.627FD14C-ON88256F56.0010B138-88256F56.001402F0@us.ibm.com>
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

On Tue, Nov 23, 2004 at 07:38:34PM -0800, Marc Eshel wrote:
> 'echo 1 > /porc/sys/fs/nfs/nlm_grace' will put lockd in grace period and
> 'echo 0 > /porc/sys/fs/nfs/nlm_grace' will take it out of grace period but
> it is not necessary to 'echo 0' since it will just come out of grace period
> when the period ends.

The "echo 0" is a little dangerous, isn't it?  Do we really need the
ability to end the grace period prematurely?--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
