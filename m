From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: locking bug
Date: Fri, 10 Dec 2004 17:05:48 -0500
Message-ID: <20041210220548.GH9291@fieldses.org>
References: <Pine.LNX.4.60.0412101428350.21479@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcstR-00056c-M6
	for nfs@lists.sourceforge.net; Fri, 10 Dec 2004 14:05:41 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CcstP-0008Cd-K0
	for nfs@lists.sourceforge.net; Fri, 10 Dec 2004 14:05:41 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0412101428350.21479@harp.ngdc.noaa.gov>
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

On Fri, Dec 10, 2004 at 02:34:32PM -0700, Ara.T.Howard wrote:
> summary:
> 
>   * process on host 0 opens file, locks it, and read it in using separate 
>   file
>     handle.  it then sleeps holding lock.
> 
>   * process on host 1 attempting the exact same sequence (and so expecting 
>   to
>     find the file locked) is able to obtain the lock.
> 
>   * if the file is not slurped this code acts as it's supposed to - process 
>   on
>     host 1 cannot obtain lock
> 
> 
> is this known?  if not should i report here or to redhat?

You understand that the close releases the lock?  From "man fcntl":

"As well as being removed by an explicit F_UNLCK, record locks are auto-
matically released when the process terminates or if it closes any file
descriptor referring to a file on which locks are held."

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
