From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: assigning filesystem ID's
Date: Fri, 5 Apr 2002 11:14:40 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15532.64128.511112.975886@notabene.cse.unsw.edu.au>
References: <Pine.LNX.4.33.0204041155430.6266-100000@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <NFS@lists.sourceforge.net>
To: David Dougall <davidd@et.byu.edu>
In-Reply-To: message from David Dougall on Thursday April 4
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

On Thursday April 4, davidd@et.byu.edu wrote:
> I heard recently that a feature had been added to the 2.5 kernel that
> allowed the fsid to be assigned in the exports file.  Has this been
> back-ported to the 2.4.x series?  Or is it just a part of the nfs-utils?
> I have had problems in the past with failover nfs servers that mount the
> partition, but it may be a different device number in /dev and therefore,
> the clients return stale mount errors.  Will the fsid setting in the
> exports file solve this problem?
> Please advise.

It is in 2.5 and 2.4.19-pre4-ac4 and later (I think).  It probably
wont be in 2.4.19 but might be in 2.4.20.

You need to get nfs-utils from the CVS on sourceforge.  There hasn't
been a release made since that functionality was added.

It should fix your problem with different /dev numbers.

NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
