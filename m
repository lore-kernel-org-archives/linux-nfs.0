From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Re: lockd grace period
Date: Tue, 1 Feb 2005 09:58:41 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0502010957000.8434@harp.ngdc.noaa.gov>
References: <20050201151342.42014.qmail@web51609.mail.yahoo.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net, steved@redhat.com, chetan@hp.com
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cw1MZ-0003sa-ST
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 08:58:51 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cw1MY-000099-Fw
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 08:58:51 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050201151342.42014.qmail@web51609.mail.yahoo.com>
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

On Tue, 1 Feb 2005, mehta kiran wrote:

>       what is servant mode ?

   client AND server => servant

>       what i am saying is that  if machine1 is  acting as NFS server than it
>       allows client to reclaim lock  when lockd restarts.  machine1 is also
>       NFS client of some other server. if NFS server on machine1 goes down ,
>       lockd wont be killed as NFS client on machine1 requires it.
>
>      Later , if NFS server is restarted on machine1 , lockd wont
>      restart(already running) and hence does not enter grace period.
>
>      Let me know if i am not  clear

   this is clear now.  thanks!

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
