From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] question about file identifier in NFS trace data
Date: Mon, 28 Aug 2006 23:58:15 -0400
Message-ID: <1156823895.5609.3.camel@localhost>
References: <OF385DC2E0.05268794-ON482571D9.000AD384-482571D9.00112132@cn.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: systemtap@sourceware.org, nfs@lists.sourceforge.net, tony.reix@bull.net,  chucklever@gmail.com
Return-path: <systemtap-return-4078-gls-systemtap=m.gmane.org@sourceware.org>
To: Xue Peng Li <xuepengl@cn.ibm.com>
In-Reply-To: <OF385DC2E0.05268794-ON482571D9.000AD384-482571D9.00112132@cn.ibm.com>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, 2006-08-29 at 11:12 +0800, Xue Peng Li wrote:
> Hi,
>     I am now working on NFS trace hooks of LKET. I want to know what file 
> is being operated for both client side and server 
> side NFS functions. On client side, two kinds of data can be used to 
> identify files, i.e. i_ino field of the inode object
> which can identify the filesystem inode on disk, and the other is NFS file 
> handler which is used to identify files between 
> client and server.On server side ,only NFS file handler received from 
> client can be used to identify file(It's very 
> complicated to convert it to inode object at nfsd_* probe point).
>  
>     I am not sure which one should be traced. If file handler is traced 
> ,there is another problem , the total length of
> file handler is 128 bytes,and for NFSV3 the length is variable. I am not 
> sure how many bytes should be traced, if 128 bytes
> are traced ,it's will so long for performance penalty, usually we only 
> trace serval bytes for one data.
> 
>    Could anyone give me some suggestions? Thanks in advance

See what we use for dprintk(): use dentries whenever possible, else use
the combination sb->s_id + fileid.

Cheers,
  Trond
