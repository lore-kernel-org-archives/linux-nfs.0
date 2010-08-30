Return-Path: <nfsv4-bounces@linux-nfs.org>
Subject: Re: [PATCH 0/2] Make libtirpc work with old style portmapper
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <201008301819.18773.okir@suse.de>
Date: Mon, 30 Aug 2010 19:48:02 -0400
Message-Id: <42F5CE2D-786B-464F-A6B7-D14FBF963F99@oracle.com>
References: <201008301503.19783.okir@suse.de>
	<30F1122D-13FB-4B6B-9BA2-99112306581F@oracle.com>
	<201008301819.18773.okir@suse.de>
To: Olaf Kirch <okir@suse.de>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>


On Aug 30, 2010, at 12:19 PM, Olaf Kirch wrote:

> On Monday 30 August 2010 17:59:18 Chuck Lever wrote:
>> Another minor problem I think I remember is that if libtirpc is used on a
>> system (perhaps because it is statically linked with said ISV RPC-enabled
>> application) that does not have /etc/netconfig installed, the transport
>> creation logic in rpcb_clnt.c simply doesn't work.
> 
> Well, but that's something that's fixed easily - we can always tell
> such customer to install an /etc/netconfig on their system.

Agreed, but for various reasons, the symptoms don't necessarily immediately imply what is needed to correct the problem.

-- 
chuck[dot]lever[at]oracle[dot]com




_______________________________________________
NOTE: THIS LIST IS DEPRECATED.  Please use linux-nfs@vger.kernel.org instead.
(To subscribe to linux-nfs@vger.kernel.org: send "subscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org.)

NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
