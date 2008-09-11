From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount
	namespace is unshared
Date: Thu, 11 Sep 2008 12:39:39 -0400
Message-ID: <02721E5E-6962-4699-86A5-EF5CFC787284@oracle.com>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com>
	<m18wu1nyon.fsf@frodo.ebiederm.org>
	<20080909152952.GA21207@us.ibm.com>
	<DE845309-1684-472A-8269-78AB3A2823A9@oracle.com>
	<m1fxo9mba5.fsf@frodo.ebiederm.org> <48C791F9.8090606@fr.ibm.com>
	<76bd70e30809100812r4a7fa71crfc7196350e3ed1cf@mail.gmail.com>
	<m1ej3rixbx.fsf@frodo.ebiederm.org> <48C8DEA0.9080905@fr.ibm.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        Andrew Morton <akpm@linux-foundation.org>
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces@lists.linux-foundation.org>
In-Reply-To: <48C8DEA0.9080905-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Sender: containers-bounces@lists.linux-foundation.org
Errors-To: containers-bounces@lists.linux-foundation.org
List-ID: <linux-nfs.vger.kernel.org>

Cedric-

On Sep 11, 2008, at Sep 11, 2008, 5:02 AM, Cedric Le Goater wrote:
>> The conservative play is to always force use of the initial namespace
>> and to deny creation of mounts that would use different  
>> namespaces.  In part
>> because the initial version of the namespace always exists.  Which  
>> means
>> as relates to Cedrics initial patch we would still need to know which
>> mounts should cause us to use a different uts namespace so we can  
>> deny
>> them.
>
> I will send the initial patch which forces use of the initial  
> namespace because
> it does fix a real oops.

Today's patch looks reasonable to me.  I would add a FIXME comment in  
net/sunrpc/clnt.c near the site of the fix.

> Then, I should be able to find some time to work on improving the  
> uts namespace
> checks when NFS mounts are done.

As a final note, I don't think this is an issue only for NFS mounts.   
The problem is with how AUTH_SYS RPC credentials are formed.

cl_nodename is a copy of utsname kept in the rpc_clnt structure for  
efficiency.  I think the auth_unix code has to be more sensitive to  
which utsname is "in effect" for each RPC request.  We probably can't  
use the same utsname for all RPC requests for the life of an RPC  
client.  And since RPC credentials are cached, we should be more  
careful about which cached credential is selected.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
