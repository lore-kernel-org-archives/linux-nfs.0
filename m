From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: 2.6 Must-fix list from lkml / lse-tech
Date: Mon, 19 May 2003 13:21:02 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16072.19870.820016.134584@notabene.cse.unsw.edu.au>
References: <OFD4267944.08E287EF-ON88256D28.007EB712-88256D28.00809B45@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19HbD4-00005I-00
	for <nfs@lists.sourceforge.net>; Sun, 18 May 2003 20:21:10 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <bruce.allan@us.ibm.com>) (for <trond.myklebust@fys.uio.no>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Mon, 19 May 2003 13:20:58 +1000
To: Bruce Allan <bruce.allan@us.ibm.com>
In-Reply-To: message from Bruce Allan on Friday May 16
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

On Friday May 16, bruce.allan@us.ibm.com wrote:
> 
> 
> 
> 
> Hi Trond/Neil,
> 
> I noticed you guys have been active in the discussions of akpm's 2.6
> must-fix list, but have not been following it all that closely.  Is there
> anything on the list w.r.t. NFS that you would like to submit to this email
> list to call for participation whether it be to request peoples' time to
> work on outstanding issues, ask for corroborating evidence of issues,
> testing of experimental patches, or whatever?
> 

Thanks for asking.

For the server side:
  There is nothing on the "must-fix" list.
  The issues that I know of are: 
    NFSv4 - which is on-going

    rpcsec-gss which needs me to put a bit more time into working with
      the guys at Umich who are working on this.

    I want to release a new nfs-utils that makes better use of the new
    functionality in nfsd.  There is a branch of the sourceforge CVS
    tagged neilb-devel which has most of the code I want to include,
    but I need to review it and be sure I am happy with it.
    Testing that would be nice.
    To enable the new functionality you
	mount -t nfsd nfsd /proc/fs/nfs
    Then mountd only ever gives export data to the kernel in response
    to an up-call. exportfs never gives data to the kernel but might
    flush the kernel's cache if it sees a need.  With this, a rejuvenated
    "crossmnt" export option should work:  If you export a directory
    with "crossmnt" then any filesystems beneath that directory are
    automatically exported aswell.  
    Finally, /var/lib/nfs/rmtab is never used and it you remove it and
    reboot, any current client mounts should continue to work.

    Finally I have had reports of poor stability with 2.5 nfsd, but I
    don't have any specific details.  If anyone wants to hammer nfsd
    nice and hard and tell me lots of details about any negative
    results, I would appreciate it.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: If flattening out C++ or Java
code to make your application fit in a relational database is painful, 
don't do it! Check out ObjectStore. Now part of Progress Software.
http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
