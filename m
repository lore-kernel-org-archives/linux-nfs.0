From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Thu, 27 Jul 2006 04:57:39 +0200
Message-ID: <200607270457.39532.agruen@suse.de>
References: <200607032310.15252.agruen@suse.de>
	<A15E619E-E88C-420C-AEC4-4E7409F187F3@Sun.COM>
	<200607270259.04405.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Cc: Sam Falkner <Sam.Falkner@sun.com>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@sun.com>,
	Brian Pawlowski <beepy@netapp.com>, nfsv4@ietf.org
Return-path: <nfsv4-bounces@ietf.org>
To: Lisa Week <Lisa.Week@sun.com>
In-Reply-To: <200607270259.04405.agruen@suse.de>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

Lisa,

On Thursday, 27. July 2006 02:59, Andreas Gruenbacher wrote:
> Let's assume that ACE4_WRITE_OWNER was indeed outside of the access control
> mechanisms defined by POSIX as a counter example. A POSIX application does
> a chmod to mode 0600 (rw-------) in order to restrict access to the file
> owner. After that, the application can perfectly well write information
> that is confidential to the owner into the file -- after all, only the
> owner will have access, right?
>
> Well, not quite, because an ACL might still grant ACE4_WRITE_OWNER to some
> other user on the system. That other user could simply take over ownership
> of the file, and do whatever he wants with it. Here we have it, a perfect
> security hole; all POSIX applications potentially broken!
>
> Therefore, there cannot be any file access control mechanisms which are
> neither defined by POSIX, nor additional or alternate.

I forgot to mention that an analogous case can be made for additional file 
access control mechanisms as well: POSIX applications cannot know which 
additional file access control mechanisms a particular implementation may 
support; they are free to rely on invariants under POSIX, such as a chmod 
from one mode to another, which should be a no-op. Additional file access 
control mechanisms must make sure that POSIX invariants will not change the 
permissions granted.

This contradicts with having a chmod write through to OWNER@, GROUP@, and 
EVERYONE@ ACEs: consider the same ACE we had before with a file mode of 0740 
(rwxr-----):

  OWNER@:READ_DATA/APPEND_DATA/EXECUTE::ALLOW

If a chmod to 0640 and back to 0740 writes through to the OWNER@ ACE, the 
entry will change to:

  OWNER@:READ_DATA/WRITE_DATA/APPEND_DATA/EXECUTE::ALLOW

So a POSIX application has added mask flags in a supposed invariant. That's 
also a security hole, but not one as severe as the first because the only 
mask flag affected is APPEND_DATA (I believe).

I have pointed this out before in Section 4.7. "Mode Changes and the OWNER@, 
GROUP@, and EVERYONE@ ACEs".

Andreas

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
