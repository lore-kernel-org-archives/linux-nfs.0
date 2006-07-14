From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: Re: [NFS] NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Fri, 14 Jul 2006 21:02:44 +0200
Message-ID: <200607142102.45216.agruen@suse.de>
References: <200607032310.15252.agruen@suse.de>
	<200607071355.30624.agruen@suse.de>
	<20060714175930.GD20999@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Sam Falkner <Sam.Falkner@sun.com>,
	Spencer Shepler <spencer.shepler@sun.com>,
	nfs@lists.sourceforge.net, Brian Pawlowski <beepy@netapp.com>
Return-path: <nfsv4-bounces@ietf.org>
To: nfsv4@ietf.org
In-Reply-To: <20060714175930.GD20999@fieldses.org>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Friday, 14. July 2006 19:59, J. Bruce Fields wrote:
> For a server that doesn't support the new attributes, the client still
> has available any of the current options: give up on non-destructive
> chmod, or fall back on representing mask bits with DENIES.

Maybe not what you meant, but shouldn't the client rely on the server to do 
"the right thing" when it sees a mode SETATTR? I think it would be a bad idea 
for the client to guess such details as which exact file security model a 
server implements. Instead, the server should be responsible for doing what 
the client is asking for (and erring towards more restrictive permissions if 
necessary).

Andreas

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
