From: mike@waychison.com
Subject: [PATCH/RFC 0/2] Userspace RPC proxying
Date: Mon, 7 Mar 2005 15:52:43 -0500 (EST)
Message-ID: <37086.66.11.176.22.1110228763.squirrel@webmail1.hrnoc.net>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: mike@waychison.com
To: "linux-nfs" <nfs@lists.sourceforge.net>,
        "autofs mailing list" <autofs@linux.kernel.org>
List-Unsubscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/pipermail/autofs>
List-Post: <mailto:autofs@linux.kernel.org>
List-Help: <mailto:autofs-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=subscribe>
Sender: autofs-bounces@linux.kernel.org
Errors-To: autofs-bounces@linux.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi All,

Every once in a while, we see complaints that nfs mounts are failing due
to there being no more reserved ports available for outbound rpc
communication.  This often happens when using TCP transports, because all
outbound connections that are closed go into a TIME_WAIT state.

Outbound RPC calls happen in both userspace and kernelspace.  The
following patches only attempt to fix the problem for userspace.

For various reasons, avoiding the TIME_WAIT state using connect(fd,
{AF_UNSPEC}, ...) or doing SO_REUSEADDR may not be the safest way to
handle things.

An alternative solution that I was kicking around last week at
connectathon is to have an RPC proxy server, that multiplexes outbound
connections and caches connections for a while.  The following two patches
to util-linux implement this idea. (Note: this is against my apt-get
source util-linux tree).

The first patch implements two pieces: the client and the proxy itself. 
The client looks to the usual caller like a regular CLIENT *, but is
created with the following call:

CLIENT *clntproxy_create(unsigned long domain, unsigned long type, struct
sockaddr *addr, unsigned long addrlen, unsigned long prog, unsigned long
vers);

The hope is that this one interface works well for IPv4/6 and TCP/UDP. 
Like the usual clnt*_create calls, you can leave addr->sin_port == 0, and
the portmapper will be consulted on your behalf.  Also, a best guess
attempt will be made if the specified version of the program cannot be
found, although this requires the portmapper to support PMAPPROC_DUMP.

The proxy is bundled as a daemon called 'rpcproxyd'.  This daemon is
implicitly started by the first call to clntproxy_create().  It deamonizes
itself and listens on a unix socket at /var/run/rpcproxyd/socket.  To
proxy, the client connects to this socket, and sends off a negotiation
packet outlining the endpoint's info, and waits for a connect error
message.  If the error message is 0, then the client works just like a
clntunix_create call.  I originally called clntunix_create from
clntproxy_create, but pulled in the clntunix code directly so that I could
override CLSET_FD_CLOSE && CLSET_FD_NCLOSE clnt_control() flags.

rpcproxyd will create outbound connections and multiplex the transports
with any number of simultaneous clients.  There is no support for
re-binding your transport once created.  It will also cache outbound
server connections for 30 seconds after last use, which greatly helps keep
the number of ports used down in a mount-storm situation.

rpcproxyd is written as a single-threaded/no-signals/select-based daemon. 
It can be run in debug mode by passing '-d' as a command line argument.

The second patch changes mount(8) and umount(8) to use the
clntproxy_create call when doing NFS stuff.

Please review and comment.

Thanks,

Mike Waychison
