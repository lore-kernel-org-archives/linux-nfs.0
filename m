From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 14/14] SUNRPC: Debugging aid
Date: Fri, 19 Jan 2007 17:38:14 -0500
Message-ID: <45B14856.4050506@oracle.com>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>	
	<20070118233100.23310.25683.stgit@localhost.localdomain>
	<1169245720.6262.27.camel@lade.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010605010208080405010607"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H82P0-0003Go-NA
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 14:40:06 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H82P2-0004DG-8v
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 14:40:08 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1169245720.6262.27.camel@lade.trondhjem.org>
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

This is a multi-part message in MIME format.
--------------010605010208080405010607
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Thu, 2007-01-18 at 18:31 -0500, Chuck Lever wrote:
>> Add helper functions for tracking the current FSM state for each RPC task.
>> The FSM state name is now displayed in rpc_show_task instead of the
>> absolute address of the FSM function.
>>
> 
> Urgh. When are we ever going to need this information?
> 
> We already have the tk_action pointer and the rpc_queue.

The tk_action pointer is useless in cases where we don't have a symbol 
map.  I've actually run into this problem in the field.

In rpc_show_tasks, I was going to do a ksymbol mapping of tk_action, and 
print the symbol name instead of the function pointer.  Unfortunately 
the ksymbol stuff just doesn't work when sunrpc is loaded as a module.

I considered your idea of replacing "tk_action = call_yada;" with a 
function or macro that would also update tk_action_name, but I think we 
get more accurate information by setting tk_action_name right at the top 
of each state function.

--------------010605010208080405010607
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmUgTGludXggUHJvamVjdHMgR3Jv
dXANCmVtYWlsO2ludGVybmV0OmNodWNrIGRvdCBsZXZlciBhdCBub3NwYW0gb3JhY2xlIGRv
dCBjb20NCnRpdGxlOlByaW5jaXBsZSBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0
OCA2MTQgNTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnZlcnNpb246Mi4xDQplbmQ6dmNh
cmQNCg0K
--------------010605010208080405010607
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------010605010208080405010607
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010605010208080405010607--
