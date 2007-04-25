From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 0/4 Revised] NLM - lock failover
Date: Wed, 25 Apr 2007 11:19:40 -0400
Message-ID: <462F718C.9060201@redhat.com>
References: <OFABDC8A62.05BC8A30-ON882572C8.00541812-882572C8.00545C53@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>,
	nfs@lists.sourceforge.net, nfs-bounces@lists.sourceforge.net
To: Marc Eshel <eshel@almaden.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <OFABDC8A62.05BC8A30-ON882572C8.00541812-882572C8.00545C53@us.ibm.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Marc Eshel wrote:
>> The detailed overall steps were described in the first email we sent 
>> *long* time (> 6 months, I think) ago. The first step of the whole 
>> process is tearing down the floating IP from the failover server. The IP 
>> is not accessible until filesystem is safely fail-over and SM_NOTIFY 
>> ready to be sent.
>>     
>
> I thought this is a solution for an active active server where a cluster 
> file system can export the same file system from multiple NFS servers.
> Marc.
>
>   

Yes ... but remember we should have two cases here:

1) Local filesystems such as ext3 - both IP and filesystem are not 
accessible during the transition.
2) Cluster filesystem such as GFS or GPFS - filesystem may still be 
accessible (depending on the configuration, say you have advertised two 
exported IP addresses, each serving different subdirectories for the 
very same cluster filesystem). The failover IP should be suspended 
during the transition until SM_NOTIFY is ready to go out (but the other 
IP should be up and services the requests as it should).

I assume people understand that the affected export entries should have 
been un-exported (as part of the over-all process).

-- Wendy


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
