From: Steve Dickson <SteveD@redhat.com>
Subject: Re: df hangs on down nfs server mounted with hard,intr,can't
 kill
Date: Mon, 15 Mar 2004 21:26:51 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <405665EB.1030002@RedHat.com>
References: <482A3FA0050D21419C269D13989C611302B07BC3@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B34IC-00029w-Ig
	for nfs@lists.sourceforge.net; Mon, 15 Mar 2004 18:26:56 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1B34IA-0005bl-Ak
	for nfs@lists.sourceforge.net; Mon, 15 Mar 2004 18:26:54 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07BC3@lavender-fe.eng.netapp.com>
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

Lever, Charles wrote:

>zeroing the RPC counters is a little outside the scope of my
>patch, as i'm providing a whole new interface that is outside
>the /proc/net/rpc/* hierarchy.  this is work that might/should
>go in separately from mine?  
>
Yes.. I agree...  they are separate... and probably should stay separate.

>but one question:  why do you use a hex value for this interface?
>  
>
Two reasons, one the debug interface uses a numeral interface and
two,  I figured since nfsstat is already converting the command line
arguments into 'flag bits',  reusing those flags bits to tell the kernel
which stats should be zeroed would be fairly clean and non intrusive
way to do it.

>i thought /proc was supposed to be human-readable.  why not use
>"z" "zc" "zs" just like your nfsstat arguments so that one can
>just as easily do:
>
>  echo "zs" > /proc/net/rpc/nfs
>
>
>  nfsstat -zs
>
>  
>
Good point... I guess I just assumed the nfsstat interface would be used.

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
