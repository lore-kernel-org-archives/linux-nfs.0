From: Tom Tucker <tom@smtp.opengridcomputing.com>
Subject: Re: [RFC,PATCH 10/10] rdma: Kconfig
Date: Tue, 10 Jul 2007 23:11:48 -0500
Message-ID: <E08E8491-AE18-4E56-8F2E-7A92B7DA3C92@smtp.opengridcomputing.com>
References: <20070701230258.29354.89949.stgit@dell3.ogc.int>
	<20070701231246.29354.4764.stgit@dell3.ogc.int>
	<Pine.LNX.4.64.0707101057390.13415@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0 (iPhone Mail 1A543a)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: James Lentini <jlentini@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8TYt-0002uR-VU
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 21:12:24 -0700
Received: from mail.es335.com ([67.65.19.105])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I8TYx-0001qq-C7
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 21:12:27 -0700
In-Reply-To: <Pine.LNX.4.64.0707101057390.13415@jlentini-linux.nane.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Agreed, this help needs updating

Tom

On Jul 10, 2007, at 10:04 AM, James Lentini <jlentini@netapp.com> wrote:

>
>
> On Sun, 1 Jul 2007, Tom Tucker wrote:
>
>>
>> Add NFS_RDMA as an option to the Kconfig file.
>>
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>> ---
>>
>> fs/Kconfig |    7 +++++++
>> 1 files changed, 7 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/Kconfig b/fs/Kconfig
>> index 0fa0c11..718006c 100644
>> --- a/fs/Kconfig
>> +++ b/fs/Kconfig
>> @@ -1652,6 +1652,13 @@ config NFSD
>>      To compile the NFS server support as a module, choose M here:  
>> the
>>      module will be called nfsd.  If unsure, say N.
>>
>> +config NFSD_RDMA
>> +    tristate "Provide NFS server over RDMA support (EXPERIMENTAL)"
>> +    depends on SUNRPC && INFINIBAND && EXPERIMENTAL
>> +    help
>> +      If you want your NFS server to support RDMA connections, say  
>> Y here
>> +      If unsure, say N.
>> +
>
> I suggest rewording this text now that the svcrdma code can be built
> as a module (Y, N, and m are now valid choices).
>
>> config NFSD_V2_ACL
>>    bool
>>    depends on NFSD

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
