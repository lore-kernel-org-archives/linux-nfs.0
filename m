From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: NFS Crashes LTSP and NFS Servers and Corrupts Data! Need
 Help!
Date: Mon, 16 Jun 2003 11:22:48 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EEDE0C8.8010509@RedHat.com>
References: <3EEA7890.3010902@lillecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, ltsp-discuss@lists.sourceforge.net,
   redhat-list@RedHat.com, jrosen@lillecorp.com
Return-path: <nfs-admin@lists.sourceforge.net>
To: Fanying Jen <fanying@lillecorp.com>
In-Reply-To: <3EEA7890.3010902@lillecorp.com>
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

Fanying Jen wrote:

> NFS Problem 1 (Crashing)
>
> The LTSP would create stale locks and eventually the LTSP server 
> crashes. Furthermore, data is corrupted during the process. 

Is there any type of errors in /var/log/messages? When you say crashes
what do you
mean? The machine oops (in that case send the oops trace) or some part
of LTSP
drops core....

> NFS Problem 2 (Corruption)
>
> This happens mostly in OpenOffice, more than once, data gets corrupted 
> and when working with both Microsoft and native OpenOffice formats. On 
> full local workstations where the files are save to the local disk, 
> this does not happen. The office docuements are normally saved to an 
> NFS filesystem. 

Boy this is a bit bizarre..... What mount options are you using?

> NFS Problem 3 (Performance)
>
> NFS is very slow over T1 and cable links but is just fine on the Local 
> Fast Ethernet. It is slow enough to either knock people off or cause 
> write errors. We are thinking the hubs play a major role and are 
> replacing with high end managed switches. However we believe that 
> there is more than meets the eye and the T1 also has something to do 
> with. 

Try using TCP over the T1 link and see if that helps....

SteveD.




-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
