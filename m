From: "G. Allen Morris III" <gam3-nfs@gam3.net>
Subject: Re: /proc/fs/nfs/exports Broken
Date: Sun, 6 Mar 2005 15:30:43 -0500
Message-ID: <20050306203043.GA5529@gam3.net>
References: <20050306164036.GA21468@gam3.net> <20050306173628.GA3918@gam3.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D82Ot-00055U-Vy
	for nfs@lists.sourceforge.net; Sun, 06 Mar 2005 12:30:55 -0800
Received: from mta10.adelphia.net ([68.168.78.202])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D82Os-00024c-I9
	for nfs@lists.sourceforge.net; Sun, 06 Mar 2005 12:30:55 -0800
Received: from harpo ([68.235.28.141]) by mta10.adelphia.net
          (InterMail vM.6.01.04.01 201-2131-118-101-20041129) with ESMTP
          id <20050306203048.QPNS7277.mta10.adelphia.net@harpo>
          for <nfs@lists.sourceforge.net>; Sun, 6 Mar 2005 15:30:48 -0500
Received: from gam3 by harpo with local (Exim 3.36 #1 (Debian))
	id 1D82Oh-0001aM-00
	for <nfs@lists.sourceforge.net>; Sun, 06 Mar 2005 15:30:43 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <20050306173628.GA3918@gam3.net>
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

On Sun, Mar 06, 2005 at 12:36:28PM -0500, G. Allen Morris III wrote:
> Neil,
> 
> Neil the net rcp export cache should not be used directly for
> the /proc/nfs/exports output.
> 
> I am pretty sure that all that needs to be done is to only display
> the rightmost element of the domain (client = strrchr(domain, ',')+1).
> 
> I have a patch, but plan to clean it up before I send it to you.
> 
> I just wanted to request comments on this problem for now.

I can see that I am very wrong about how simple this is. I think that
extra data or code is needed to solve this problem.

Here are some questions:
 1. do we need nfsd/exports at all? (No ones seems to have noticed that
    the information it gives is not very human readable.)
 2. If yes. What is it for? It seems to me it is needed to show what
    export a given IP is mapped to.
 3. Should exportfs have a switch that to display the kernel export
    cache is some nice format or formats.

Allen Morris <gam3@gam3.net>


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
