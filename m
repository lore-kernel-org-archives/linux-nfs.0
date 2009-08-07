From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [Patch 6/10] NFS Mount Configuration File (Vers 3)
Date: Fri, 07 Aug 2009 13:34:12 -0400
Message-ID: <4A7C6594.7040700@RedHat.com>
References: <4A7B2324.9090406@RedHat.com> <4A7B24D0.1060209@RedHat.com>
	<95B06B96-FCFB-49FA-ACA6-3E336DB5BE33@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <95B06B96-FCFB-49FA-ACA6-3E336DB5BE33@oracle.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/06/2009 04:44 PM, Chuck Lever wrote:
> 
> Seems to me the text-based mount option parser routines (parse_opt.[ch])
> already does a lot of this.  It can break up a string into a linked list
> of options, handle quoted commas properly, catenate options to the list,
> and flatten the list back into a C string.
Well I patterned the code after the file parsing code in idmap daemon
which means there a common theme between both the idmap configuration
file and the mount configuration. I think that is important. 
 
> 
> Wouldn't it be easier to adapt that code rather than adding new code
> that does nearly the same thing?  It would save you a lot of C string
> manipulation, and reuse working code.
At this point, no. and I am reuse a lot of code...

steved.
