From: "Duv  Dek" <onur@ee.bilkent.edu.tr>
Subject: Re: NFS response time
Date: Wed, 26 Jan 2005 00:00:11 +0200
Message-ID: <004101c50329$3e016b30$7889b38b@alpin>
References: <003a01c50326$73182550$7889b38b@alpin> <41F6BD96.4040409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=response
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtYjZ-0001Bz-QA
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 14:00:25 -0800
Received: from dalyan.ee.bilkent.edu.tr ([139.179.12.25])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CtYjW-00039a-HB
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 14:00:25 -0800
To: "Neil Horman" <nhorman@redhat.com>
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

Yes, it is program that we wrote. It is doing some mathematical 
calculations, so it utilizes full CPU. Other linux programs are not getting 
very slow when this program runs, but client computers sometimes wait half a 
minute in order to reach a file on nfs server. Logging in to the client 
computers take around 10 minutes. Normally it takes no more than 20 seconds. 
I mean nfs  is almost locking, but no other linux program is badly affected. 
At least we should be able to give better priority nfs via renice but we 
couldn't figure it out. Doing renice -20 to all root programs didn't make 
nfs faster.



----- Original Message ----- 
From: "Neil Horman" <nhorman@redhat.com>
To: "Duv Dek" <onur@ee.bilkent.edu.tr>
Cc: <nfs@lists.sourceforge.net>
Sent: Tuesday, January 25, 2005 11:43 PM
Subject: Re: [NFS] NFS response time


> Duv Dek wrote:
>> Hi
>>  We have a problem with our NFS server on Redhat 9. In case a program on 
>> the server uses high CPU, the NFS clients almost lock and nfs stops 
>> giving response until that program lowers its CPU usage.  We tried to 
>> increase the priority of nfsd deamons with renice, and also tried to 
>> increase the number of nfsd threads, decreased the priority of the 
>> program using high CPU with renice, but none of them worked. How can we 
>> solve this problem so that nfs does not lock?
>>
> Have your tried to ascertain which process on your system is responsible 
> (or most responsible) for the high CPU utilization?
>
> Neil
>
> -- 
> /***************************************************
>  *Neil Horman
>  *Software Engineer
>  *Red Hat, Inc.
>  *nhorman@redhat.com
>  *gpg keyid: 1024D / 0x92A74FA1
>  *http://pgp.mit.edu
>  ***************************************************/
> 



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
