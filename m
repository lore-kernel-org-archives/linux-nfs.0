From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: Re: lockd grace period
Date: Tue, 1 Feb 2005 07:13:42 -0800 (PST)
Message-ID: <20050201151342.42014.qmail@web51609.mail.yahoo.com>
References: <Pine.LNX.4.60.0502010745140.8434@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, steved@redhat.com, chetan@hp.com
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cvziv-00062R-VY
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 07:13:49 -0800
Received: from web51609.mail.yahoo.com ([206.190.38.214])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1Cvziu-0007XG-8f
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 07:13:49 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0502010745140.8434@harp.ngdc.noaa.gov>
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

Hi Ara , 
       what is servant mode ?
       what i am saying is that  if machine1
      is  acting as NFS server than it allows client  
    
       to reclaim lock  when lockd restarts.
       machine1 is also  NFS client
       of some other server. if NFS server on 
       machine1 goes down , lockd wont be killed
       as NFS client on machine1 requires it.

      Later , if NFS server is restarted on 
      machine1 , lockd wont restart(already running)
      and hence does not enter grace period.
      
      Let me know if i am not  clear

regards,
 --kiran

--- "Ara.T.Howard" <Ara.T.Howard@noaa.gov> wrote:

> On Tue, 1 Feb 2005, mehta kiran wrote:
> 
> > What i think is that suse does it right by
> restarting nfs grace period of
> > already running lockd.  This is because machine
> acting as nfs server can
> > definitely act as nfs client of some other
> machine(though rare but occurs).
> 
> for us it is not rare; we do it all the time.  do i
> understand correctly; that
> the result of NOT re-entering grace period in
> servant mode would be failure to
> re-claim locks?
> 
> cheers.
> 
> -a
> -- 
>
===============================================================================
> | EMAIL   :: Ara [dot] T [dot] Howard [at] noaa
> [dot] gov
> | PHONE   :: 303.497.6469
> | When you do something, you should burn yourself
> completely, like a good
> | bonfire, leaving no trace of yourself.  --Shunryu
> Suzuki
>
===============================================================================
> 
> 
>
-------------------------------------------------------
> This SF.Net email is sponsored by: IntelliVIEW --
> Interactive Reporting
> Tool for open source databases. Create drag-&-drop
> reports. Save time
> by over 75%! Publish reports on the web. Export to
> DOC, XLS, RTF, etc.
> Download a FREE copy at
> http://www.intelliview.com/go/osdn_nl
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
