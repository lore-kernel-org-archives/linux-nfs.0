From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: clear_locks on Linux?
Date: Wed, 13 Apr 2005 06:31:51 -0700 (PDT)
Message-ID: <20050413133151.79772.qmail@web51602.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DLhyL-0006xi-3Q
	for nfs@lists.sourceforge.net; Wed, 13 Apr 2005 06:32:01 -0700
Received: from web51602.mail.yahoo.com ([206.190.38.207])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1DLhyH-0002nN-PI
	for nfs@lists.sourceforge.net; Wed, 13 Apr 2005 06:32:00 -0700
To: eh@dataconnection.com, nfs@lists.sourceforge.net
In-Reply-To: 6667
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

Hi , 
    1.You can definitely restart nfsd so that clients 
      will reacquire their locks.
    2.If you only want to release all locks , use
      kill -9 <lockd pid> but in this case all 
      clients will looose their locks permanently.
      
I dont think that currently there is any way to
release locks held  by --a-- particlar client. 

regards,
 kiran


--- eh@dataconnection.com wrote:
> Solaris has a command clear_locks, to remove locks
> held by a specific remote host.
> 
> Does Linux have a similar command?  I'm having
> trouble finding one.  I have very occasionally seen
> a situation where a client crashes hard, leaving a
> file lock held on an NFS server, and I want to have
> a way to remove it.
> 
> Alternatively, could I achieve a similar effect by
> restarting lockd to encourage all active clients to
> reacquire their locks?
> 
> Edward.
> 


		
__________________________________ 
Do you Yahoo!? 
Make Yahoo! your home page 
http://www.yahoo.com/r/hs


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
