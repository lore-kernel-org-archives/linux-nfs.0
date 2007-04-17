From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] rpcgss : RPC_GSS_PROC_DESTROY request will get a bad rpc
	reply message
Date: Tue, 17 Apr 2007 09:09:58 -0400
Message-ID: <20070417130958.GA11907@fieldses.org>
References: <461B5E8D.6070005@cn.fujitsu.com> <46247F90.8030106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFSv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <46247F90.8030106@cn.fujitsu.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Apr 17, 2007 at 04:04:32PM +0800, Wei Yongjun wrote:
> Does anyone think this is a BUG of kernel RPCGSS? Although this seems 
> not be used yet.

Apologies for not responding to the earlier mail; yes, I agree that this
patch is needed; thanks!  Applied.--b.
